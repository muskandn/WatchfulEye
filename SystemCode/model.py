import cv2
import numpy as np
from keras.models import load_model
import tensorflow as tf
from multiprocessing import Process
from firebase_admin import messaging, credentials, storage
import firebase_admin
from datetime import datetime
import threading
import time

hit = False
hit_sensitivity = 0
# If zero written here captures from laptop camera otherwise we can also pass in a video file here
device_id = './input.mp4'
cap = cv2.VideoCapture(device_id)

camera_fps = 30  # camera fps set to 30 by default can be changed to any other value
# how much time it'll wait (Note it may wait longer or slower depending upon how much fps your camera has and how much you have written)
footage_seconds = 5
# the code will wait till it gets camera_fps * footage_seconds number of frames regardless of the time taken for the frames to accumulate
topic = 'org1'

frames = []
counter = 0
flag = False
start_splicing = False
model = load_model('model_hawkeye')

cred = credentials.Certificate(
    "hawkeye-abd94-firebase-adminsdk-vz5ev-e084e72618.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'hawkeye-abd94.appspot.com'
})
bucket = storage.bucket()

def prediction(current_frames, original_footage):
    current_frames = current_frames.reshape(1, 64, 224, 224, 5)
    prediction = model.predict(current_frames)

    if prediction[0][0] > 0.75:  # Assuming model predicts as [Nonviolence,Violence]
        global hit
        hit = True
        print("Violence Detected")
