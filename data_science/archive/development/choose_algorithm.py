import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from algorithms.correlation_based import detect_outlier_streams


def mean_based(*args, **kwargs):
    raise NotImplementedError('Archived mean-based runtime path is not enabled in this environment.')


def volatility_based(*args, **kwargs):
    raise NotImplementedError('Archived volatility-based runtime path is not enabled in this environment.')


def correlation_based(df, streams, start_date, end_date, threshold=None):
    return detect_outlier_streams(df, streams, start_date, end_date, threshold)

def choose_algorithm(df, streams, start_date, end_date, threshold=None, type='correlation'):
    if type == 'correlation':
        return correlation_based(df, streams, start_date, end_date, threshold)
    elif type == 'mean':
        return mean_based(df, streams, start_date, end_date, threshold)
    elif type == 'volatility':
        return volatility_based(df, streams, start_date, end_date, threshold)
    else:
        raise ValueError('Not a valid choice')
