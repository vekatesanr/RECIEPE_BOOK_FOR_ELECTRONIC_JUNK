import os
import shutil
import subprocess
import sys

def install_dependencies():
    print("Checking/Installing dependencies (ultralytics)...")
    try:
        import ultralytics
        print(f"Ultralytics {ultralytics.__version__} is already installed.")
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "ultralytics"])
        print("Ultralytics installed successfully.")

def train_model():
    from ultralytics import YOLO
    import torch

    # Check for GPU
    device = 0 if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device} ({'NVIDIA GPU' if device == 0 else 'CPU'})")

    # Load Nano model (pre-trained on COCO for transfer learning)
    print("Loading base YOLOv8n model...")
    model = YOLO('yolov8n.pt')

    # Start training
    print("Starting training on custom dataset...")
    results = model.train(
        data='data_local.yaml',
        epochs=50,
        imgsz=640,
        device=device,
        plots=True
    )
    
    print("Training complete!")
    return model

def export_and_deploy(model):
    print("Exporting model to TFLite format for mobile...")
    # Export to TFLite
    # Note: imgsz must match training or be 640
    tflite_path = model.export(format='tflite', imgsz=640)
    
    # YOLOv8 export usually creates a folder like 'runs/detect/train/weights/best_saved_model/best_float32.tflite'
    # or just returns the path to the .tflite file.
    # In newer versions, it might be in 'best_saved_model' directory.
    
    target_dir = os.path.join('assets', 'models')
    os.makedirs(target_dir, exist_ok=True)
    target_file = os.path.join(target_dir, 'yolov8.tflite')

    # Find the tflite file
    # If tflite_path is a directory, look inside
    source_file = None
    if os.path.isdir(tflite_path):
        for root, dirs, files in os.walk(tflite_path):
            for file in files:
                if file.endswith('.tflite'):
                    source_file = os.path.join(root, file)
                    break
    elif tflite_path.endswith('.tflite'):
        source_file = tflite_path

    if source_file and os.path.exists(source_file):
        shutil.copy(source_file, target_file)
        print(f"✅ Model deployed to: {target_file}")
    else:
        print(f"❌ Could not find exported TFLite file at {tflite_path}")

if __name__ == "__main__":
    install_dependencies()
    model = train_model()
    export_and_deploy(model)
