import cv2
import numpy as np
from ultralytics import YOLO

# Load Models
yolov8_model = YOLO("checkpoints/best.pt")
yolov8_classes = [
    "apple", "avocado", "banana", "bell_pepper", "blueberries", "butter", "carrot", "cheese", "chicken", "cucumber",
    "eggs", "ketchup", "lemon", "lettuce", "lime", "mayonnaise", "milk", "mustard", "orange", "sour_cream", "strawberries", "tomato", "yogurt"
]

world_model = YOLO("checkpoints/yolov8s-worldv2.pt")
prompts = [
    "apple", "banana", "cheese", "yogurt", "butter", "milk", "unknown packaged food",
    "packet", "bottle", "container", "jar", "can", "leftovers", "sauce", "ready meal"
]
world_model.set_classes(prompts)


def run_detection(image_bytes):
    # Convert bytes to OpenCV image
    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    # YOLOv8 detection
    yolov8_results = yolov8_model.predict(img, save=False, verbose=False)[0]
    yolov8_detections = [yolov8_classes[int(box.cls)] for box in yolov8_results.boxes]

    # YOLOv8s-World detection
    world_results = world_model.predict(img, save=False, verbose=False)[0]
    zsd_detections = [world_model.names[int(box.cls)] for box in world_results.boxes]

    return yolov8_detections, zsd_detections