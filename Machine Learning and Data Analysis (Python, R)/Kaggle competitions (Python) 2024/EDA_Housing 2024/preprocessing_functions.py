from sklearn.base import BaseEstimator,TransformerMixin
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, PolynomialFeatures
from sklearn.compose import make_column_transformer
from sklearn.feature_selection import VarianceThreshold
import pandas as pd

class ObjToCat(BaseEstimator, TransformerMixin):
    def __init__(self):
        pass

    def fit(self, X, y=None):
        return self
    
    def transform(self, X, y=None):
        obj_cols = X.columns[X.dtypes == "object"]
        X_neu = X.copy()
        X_neu[obj_cols] = X_neu[obj_cols].astype('string')
        X_neu[obj_cols] = X_neu[obj_cols].astype('category')
        return X_neu
    