"""
Bangla SMS Spam Detection Model Training
Uses the BangalaBarta dataset to train a neural network classifier
"""

import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import json
import os
import re
from datetime import datetime

# Set random seeds for reproducibility
np.random.seed(42)
tf.random.set_seed(42)

class BanglaSpamDetector:
    def __init__(self, dataset_path, max_words=10000, max_len=100):
        self.dataset_path = dataset_path
        self.max_words = max_words
        self.max_len = max_len
        self.tokenizer = None
        self.label_encoder = None
        self.model = None
        
    def load_and_preprocess_data(self):
        """Load the CSV dataset and preprocess"""
        print("📊 Loading dataset...")
        df = pd.read_csv(self.dataset_path)
        
        print(f"Dataset shape: {df.shape}")
        print(f"Label distribution:\n{df['label'].value_counts()}")
        
        # Clean text data
        df['text'] = df['text'].fillna('')
        df['text'] = df['text'].apply(self.clean_text)
        
        # Encode labels
        self.label_encoder = LabelEncoder()
        df['label_encoded'] = self.label_encoder.fit_transform(df['label'])
        
        # Save label mapping
        label_mapping = {
            int(i): label 
            for i, label in enumerate(self.label_encoder.classes_)
        }
        with open('label_mapping.json', 'w', encoding='utf-8') as f:
            json.dump(label_mapping, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Label mapping: {label_mapping}")
        
        return df
    
    def clean_text(self, text):
        """Clean and normalize Bangla text"""
        # Remove URLs
        text = re.sub(r'http\S+|www\S+|https\S+', '', text, flags=re.MULTILINE)
        # Remove phone numbers
        text = re.sub(r'\+?\d{10,14}', '', text)
        # Remove extra whitespace
        text = ' '.join(text.split())
        return text.strip()
    
    def create_tokenizer(self, texts):
        """Create and fit tokenizer on Bangla text"""
        print("🔤 Creating tokenizer...")
        
        # Use character-level tokenization for Bangla
        self.tokenizer = keras.preprocessing.text.Tokenizer(
            num_words=self.max_words,
            char_level=False,
            oov_token='<OOV>'
        )
        self.tokenizer.fit_on_texts(texts)
        
        # Save tokenizer config
        tokenizer_config = {
            'max_words': self.max_words,
            'max_len': self.max_len,
            'word_index_size': len(self.tokenizer.word_index)
        }
        with open('tokenizer_config.json', 'w', encoding='utf-8') as f:
            json.dump(tokenizer_config, f, ensure_ascii=False, indent=2)
        
        # Save word index (limited to max_words)
        word_index = {
            word: idx 
            for word, idx in self.tokenizer.word_index.items() 
            if idx < self.max_words
        }
        with open('word_index.json', 'w', encoding='utf-8') as f:
            json.dump(word_index, f, ensure_ascii=False)
        
        print(f"✅ Vocabulary size: {len(self.tokenizer.word_index)}")
        
    def prepare_sequences(self, texts):
        """Convert texts to padded sequences"""
        sequences = self.tokenizer.texts_to_sequences(texts)
        padded = keras.preprocessing.sequence.pad_sequences(
            sequences, 
            maxlen=self.max_len,
            padding='post',
            truncating='post'
        )
        return padded
    
    def build_model(self, num_classes):
        """Build LSTM-based neural network"""
        print("🏗️  Building model architecture...")
        
        model = keras.Sequential([
            # Embedding layer
            keras.layers.Embedding(
                input_dim=self.max_words,
                output_dim=128,
                input_length=self.max_len
            ),
            
            # Bidirectional LSTM layers
            keras.layers.Bidirectional(
                keras.layers.LSTM(64, return_sequences=True)
            ),
            keras.layers.Dropout(0.3),
            
            keras.layers.Bidirectional(
                keras.layers.LSTM(32)
            ),
            keras.layers.Dropout(0.3),
            
            # Dense layers
            keras.layers.Dense(64, activation='relu'),
            keras.layers.Dropout(0.2),
            
            # Output layer
            keras.layers.Dense(num_classes, activation='softmax')
        ])
        
        model.compile(
            optimizer='adam',
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print(model.summary())
        self.model = model
        return model
    
    def train(self, X_train, y_train, X_val, y_val, epochs=10, batch_size=32):
        """Train the model"""
        print("🚀 Starting training...")
        
        # Callbacks
        callbacks = [
            keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=3,
                restore_best_weights=True
            ),
            keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=2,
                min_lr=1e-6
            ),
            keras.callbacks.ModelCheckpoint(
                'best_model.h5',
                monitor='val_accuracy',
                save_best_only=True
            )
        ]
        
        history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1
        )
        
        return history
    
    def evaluate(self, X_test, y_test):
        """Evaluate model performance"""
        print("\n📈 Evaluating model...")
        
        loss, accuracy = self.model.evaluate(X_test, y_test, verbose=0)
        print(f"Test Loss: {loss:.4f}")
        print(f"Test Accuracy: {accuracy:.4f}")
        
        # Detailed predictions
        y_pred = self.model.predict(X_test, verbose=0)
        y_pred_classes = np.argmax(y_pred, axis=1)
        
        # Classification report
        from sklearn.metrics import classification_report, confusion_matrix
        
        print("\n📊 Classification Report:")
        print(classification_report(
            y_test, 
            y_pred_classes,
            target_names=self.label_encoder.classes_
        ))
        
        print("\n🔢 Confusion Matrix:")
        print(confusion_matrix(y_test, y_pred_classes))
        
        return accuracy
    
    def convert_to_tflite(self):
        """Convert model to TensorFlow Lite format"""
        print("\n📱 Converting to TensorFlow Lite...")
        
        # Convert to TFLite with SELECT_TF_OPS for LSTM support
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,  # Enable TensorFlow Lite ops
            tf.lite.OpsSet.SELECT_TF_OPS     # Enable TensorFlow ops (for LSTM)
        ]
        converter._experimental_lower_tensor_list_ops = False
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        tflite_model = converter.convert()
        
        # Save TFLite model
        tflite_path = '../mobile/assets/fraud_model.tflite'
        os.makedirs(os.path.dirname(tflite_path), exist_ok=True)
        
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        # Also save locally for testing
        with open('fraud_model.tflite', 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ TFLite model saved ({len(tflite_model) / 1024:.2f} KB)")
        print(f"   - Mobile app: {tflite_path}")
        print(f"   - Local: fraud_model.tflite")
        
        return tflite_path



def main():
    print("=" * 60)
    print("🛡️  BANGLA SMS SPAM DETECTION - MODEL TRAINING")
    print("=" * 60)
    
    # Initialize detector
    detector = BanglaSpamDetector(
        dataset_path='../docs/BangalaBarta bangla_spam_sms smishing.csv',
        max_words=10000,
        max_len=100
    )
    
    # Load and preprocess data
    df = detector.load_and_preprocess_data()
    
    # Split data
    X_train, X_temp, y_train, y_temp = train_test_split(
        df['text'], df['label_encoded'],
        test_size=0.3, random_state=42, stratify=df['label_encoded']
    )
    
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp,
        test_size=0.5, random_state=42, stratify=y_temp
    )
    
    print(f"\n📂 Dataset split:")
    print(f"   Training: {len(X_train)}")
    print(f"   Validation: {len(X_val)}")
    print(f"   Testing: {len(X_test)}")
    
    # Create tokenizer
    detector.create_tokenizer(X_train)
    
    # Prepare sequences
    X_train_seq = detector.prepare_sequences(X_train)
    X_val_seq = detector.prepare_sequences(X_val)
    X_test_seq = detector.prepare_sequences(X_test)
    
    # Build and train model
    num_classes = len(detector.label_encoder.classes_)
    detector.build_model(num_classes)
    
    history = detector.train(
        X_train_seq, y_train.values,
        X_val_seq, y_val.values,
        epochs=15,
        batch_size=32
    )
    
    # Evaluate
    accuracy = detector.evaluate(X_test_seq, y_test.values)
    
    # Convert to TFLite
    detector.convert_to_tflite()
    
    # Save final model
    detector.model.save('spam_detector_model.h5')
    print("\n✅ Keras model saved: spam_detector_model.h5")
    
    # Save training info
    training_info = {
        'timestamp': datetime.now().isoformat(),
        'dataset_size': len(df),
        'num_classes': num_classes,
        'classes': detector.label_encoder.classes_.tolist(),
        'test_accuracy': float(accuracy),
        'max_words': detector.max_words,
        'max_len': detector.max_len
    }
    
    with open('training_info.json', 'w', encoding='utf-8') as f:
        json.dump(training_info, f, ensure_ascii=False, indent=2)
    
    print("\n" + "=" * 60)
    print("✅ TRAINING COMPLETE!")
    print(f"   Final Accuracy: {accuracy * 100:.2f}%")
    print("=" * 60)


if __name__ == '__main__':
    main()
