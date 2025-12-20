"""
Test the trained spam detection model
"""

import tensorflow as tf
import numpy as np
import json

# Load tokenizer config and word index
with open('tokenizer_config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

with open('word_index.json', 'r', encoding='utf-8') as f:
    word_index = json.load(f)

with open('label_mapping.json', 'r', encoding='utf-8') as f:
    label_mapping = json.load(f)

# Test samples
test_messages = [
    "সোনালী ব্যাংক অ্যাকাউন্টে সমস্যা হয়েছে। কল করুন: +8801818788890",
    "আপনি ৩ ভরি সোনা জিতেছেন! বিস্তারিত জানতে কল করুন",
    "শুভ জন্মদিন! তোমার সব ইচ্ছা পূরণ হোক",
    "বিশেষ অফার! সব পণ্যে ২৫% ছাড়। আজই শপিং করুন",
    "ক্রিপ্টো বিনিয়োগে লাভবান হন! আজই শুরু করুন",
]

expected_labels = ["smish", "smish", "normal", "promo", "smish"]


def preprocess_text(text, word_index, max_len):
    """Preprocess text like in training"""
    # Simple tokenization
    words = text.lower().split()
    sequence = [word_index.get(word, 1) for word in words]  # 1 is OOV token
    
    # Pad sequence
    if len(sequence) < max_len:
        sequence = sequence + [0] * (max_len - len(sequence))
    else:
        sequence = sequence[:max_len]
    
    return np.array([sequence])


def test_tflite_model():
    """Test the TFLite model"""
    print("=" * 60)
    print("🧪 TESTING TFLITE MODEL")
    print("=" * 60)
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path='fraud_model.tflite')
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"\n📊 Model Info:")
    print(f"   Input shape: {input_details[0]['shape']}")
    print(f"   Output shape: {output_details[0]['shape']}")
    
    # Test each message
    print("\n🔍 Testing messages:\n")
    correct = 0
    
    for i, (message, expected) in enumerate(zip(test_messages, expected_labels)):
        # Preprocess
        input_data = preprocess_text(message, word_index, config['max_len'])
        input_data = input_data.astype(np.float32)
        
        # Run inference
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        
        # Get prediction
        predicted_class = np.argmax(output_data[0])
        confidence = output_data[0][predicted_class]
        predicted_label = label_mapping[str(predicted_class)]
        
        # Display result
        is_correct = predicted_label == expected
        if is_correct:
            correct += 1
        
        status = "✅" if is_correct else "❌"
        print(f"{status} Test {i+1}:")
        print(f"   Message: {message[:60]}...")
        print(f"   Expected: {expected}")
        print(f"   Predicted: {predicted_label} (confidence: {confidence:.2%})")
        print()
    
    accuracy = correct / len(test_messages)
    print(f"📈 Test Accuracy: {accuracy * 100:.1f}% ({correct}/{len(test_messages)})")
    print("=" * 60)


def test_keras_model():
    """Test the Keras model"""
    print("\n" + "=" * 60)
    print("🧪 TESTING KERAS MODEL")
    print("=" * 60)
    
    # Load Keras model
    model = tf.keras.models.load_model('spam_detector_model.h5')
    
    print(f"\n📊 Model loaded successfully")
    
    # Test each message
    print("\n🔍 Testing messages:\n")
    correct = 0
    
    for i, (message, expected) in enumerate(zip(test_messages, expected_labels)):
        # Preprocess
        input_data = preprocess_text(message, word_index, config['max_len'])
        
        # Run inference
        predictions = model.predict(input_data, verbose=0)
        
        # Get prediction
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        predicted_label = label_mapping[str(predicted_class)]
        
        # Display result
        is_correct = predicted_label == expected
        if is_correct:
            correct += 1
        
        status = "✅" if is_correct else "❌"
        print(f"{status} Test {i+1}:")
        print(f"   Message: {message[:60]}...")
        print(f"   Expected: {expected}")
        print(f"   Predicted: {predicted_label} (confidence: {confidence:.2%})")
        
        # Show all class probabilities
        print(f"   All predictions:")
        for class_idx, prob in enumerate(predictions[0]):
            class_name = label_mapping[str(class_idx)]
            print(f"      {class_name}: {prob:.2%}")
        print()
    
    accuracy = correct / len(test_messages)
    print(f"📈 Test Accuracy: {accuracy * 100:.1f}% ({correct}/{len(test_messages)})")
    print("=" * 60)


if __name__ == '__main__':
    print("\n🛡️  SPAM DETECTION MODEL TEST SUITE\n")
    
    # Test Keras model
    test_keras_model()
    
    # Test TFLite model
    test_tflite_model()
    
    print("\n✅ Testing complete!")
