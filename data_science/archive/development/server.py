import sys
import os
import pandas as pd
from flask import Flask, request, jsonify
import json
import numpy as np
from prometheus_client import Counter, Histogram, CollectorRegistry, generate_latest, CONTENT_TYPE_LATEST

UPLOAD_FOLDER = os.path.join('data_science', 'storage')

# ensure the project root is on the import path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from choose_algorithm import choose_algorithm

app = Flask(__name__)

registry = CollectorRegistry()
request_counter = Counter('iot_archived_analytics_requests_total', 'Total requests to the archived analytics service', ['route', 'status'], registry=registry)
request_duration = Histogram('iot_archived_analytics_request_duration_seconds', 'Request duration for the archived analytics service', ['route'], registry=registry)

@app.route('/')
def home():
    request_counter.labels(route='/', status='200').inc()
    return "Server is up. POST JSON to /analyze"


@app.route('/health', methods=['GET'])
def health():
    request_counter.labels(route='/health', status='200').inc()
    return jsonify({'status': 'ok', 'service': 'archived-analytics'})


@app.route('/metrics', methods=['GET'])
def metrics():
    return generate_latest(registry), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/analyze', methods=['POST'])
def analyze():
    timer = request_duration.labels(route='/analyze').time()
    try:
        streams = json.loads(request.form.get('streams')) if request.form.get('streams') else []
        start_date = request.form.get('start_date')
        end_date = request.form.get('end_date')
        threshold = float(request.form.get('threshold'))
        algo_type = request.form.get('algo_type')

        uploaded_file = request.files.get('file')
        if not uploaded_file:
            request_counter.labels(route='/analyze', status='400').inc()
            return 'No files were sent', 400

        if uploaded_file.filename == '':
            request_counter.labels(route='/analyze', status='400').inc()
            return 'No files selected', 400

        os.makedirs(UPLOAD_FOLDER, exist_ok=True)

        save_path = os.path.join(UPLOAD_FOLDER, uploaded_file.filename)
        uploaded_file.save(save_path)

        try:
            # Read CSV directly from file path
            df = pd.read_csv(save_path, parse_dates=['created_at'])
            df.sort_values(by='created_at', inplace=True)
            df.set_index('created_at', inplace=True)
            df = df.interpolate()

        except Exception as e:
            request_counter.labels(route='/analyze', status='400').inc()
            return f'Error in reading CSV: {e}', 400

        # run analysis
        try:
            result = choose_algorithm(df, streams, start_date, end_date, threshold, algo_type)
        except Exception as e:
            print('e', e)
            request_counter.labels(route='/analyze', status='400').inc()
            return jsonify({'error': str(e)}), 400

        print('result', result)

        clean_result = {}
        for stream, metrics in result.items():
            clean_metrics = {k: to_native(v) for k, v in metrics.items()}
            clean_result[stream] = clean_metrics

        request_counter.labels(route='/analyze', status='200').inc()
        return jsonify({"result": clean_result})
    finally:
        timer.observe_duration()

def to_native(val):
    if isinstance(val, np.generic):
        return val.item()
    return val

if __name__ == "__main__":
    # debug=True for auto-reload on edits
    app.run(host="0.0.0.0", port=5000, debug=False)
