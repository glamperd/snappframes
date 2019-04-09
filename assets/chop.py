#install opencv-python

import cv2
import os
import time
import json
from hashlib import sha256


def chop(video_path, image_dir):
    cap = cv2.VideoCapture(video_path)

    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    print('Frame count: {}, FPS: {}'.format(frame_count, fps))

    data = {'frames': []}
    zeros_number = len(str(frame_count))

    current_frame_number = 1
    success, image = cap.read()
    while success:
        print('{}% processed'.format(int(current_frame_number / frame_count * 100)))
        image_name = '{}.jpg'.format(str(current_frame_number).zfill(zeros_number))
        cv2.imwrite(os.path.join(image_dir, image_name), image)

        image_bytes = cv2.imencode('.jpg', image)[1].tobytes()
        image_hash = sha256(image_bytes).hexdigest()
        data['frames'].append({'frame': current_frame_number, 'image_name': image_name, 'hash': image_hash})

        success, image = cap.read()
        current_frame_number += 1

    return data


# very expensive, due to changing FPS program can take 10x longer to proccess the video
def chop_changing_framerate(video_path, image_dir, fps=24):
    cap = cv2.VideoCapture(video_path)

    actual_fps = cap.get(cv2.CAP_PROP_FPS)
    actual_frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    frame_count = round(actual_frame_count * fps / actual_fps)
    print('Actual frame count: {}, Actual FPS: {}'.format(actual_frame_count, actual_fps))
    print('Target frame count: {}, Target FPS: {}'.format(frame_count, fps))

    offset_msec = 1000 / fps
    zeros_number = len(str(frame_count))

    data = {'frames': []}
    current_frame_number = 1
    success, image = cap.read()
    while success:
        print('{}% processed'.format(int(current_frame_number / actual_frame_count * 100)))
        image_name = '{}.jpg'.format(str(current_frame_number).zfill(zeros_number))
        cv2.imwrite(os.path.join(image_dir, image_name), image)

        image_bytes = cv2.imencode('.jpg', image)[1].tobytes()
        image_hash = sha256(image_bytes).hexdigest()
        data['frames'].append({'frame': current_frame_number, 'image_name': image_name, 'hash': image_hash})

        cap.set(cv2.CAP_PROP_POS_MSEC, current_frame_number * offset_msec)
        success, image = cap.read()
        current_frame_number += 1

    return data


if __name__ == '__main__':
    video_path = './Fight Club - Ending scene.mp4'
    image_dir = './fight-club-frames/'
    data_filename = 'data.json'

    if not os.path.exists(image_dir):
        os.makedirs(image_dir)

    start_time = time.time()

    data = chop(video_path, image_dir)
    with open(data_filename, 'w') as data_file:
        json.dump(data, data_file)

    print('Done in %d s.' % int(time.time() - start_time))
