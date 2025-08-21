def merge_detections(yolov8_dets, zsd_dets):
    merged = set(yolov8_dets)  # Trust YOLOv8 for known classes

    for item in zsd_dets:
        if item not in merged:
            merged.add(item)

    return list(merged)