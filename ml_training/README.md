# Bangla SMS Spam Detection - ML Training

This directory contains the machine learning training pipeline for the fraud detection system.

## Setup

1. **Create virtual environment** (recommended):
```bash
python3 -m venv venv
source venv/bin/activate  # On Mac/Linux
```

2. **Install dependencies**:
```bash
pip install -r requirements.txt
```

## Training

Run the training script:
```bash
python train_model.py
```

This will:
- Load the Bangla spam dataset
- Preprocess and tokenize the text
- Train a Bidirectional LSTM model
- Evaluate performance
- Convert to TensorFlow Lite format
- Save models and configurations

## Testing

Test the trained model:
```bash
python test_model.py
```

## Output Files

After training, you'll get:
- `fraud_model.tflite` - TensorFlow Lite model for mobile
- `spam_detector_model.h5` - Full Keras model
- `word_index.json` - Vocabulary mapping
- `label_mapping.json` - Class labels
- `tokenizer_config.json` - Tokenizer configuration
- `training_info.json` - Training metadata

## Model Architecture

- **Embedding Layer**: 128 dimensions
- **Bidirectional LSTM**: 64 units + 32 units
- **Dropout**: 0.3, 0.3, 0.2
- **Dense**: 64 units
- **Output**: Softmax (3 classes: normal, promo, smish)

## Expected Accuracy

Target accuracy: **>90%** on test set
