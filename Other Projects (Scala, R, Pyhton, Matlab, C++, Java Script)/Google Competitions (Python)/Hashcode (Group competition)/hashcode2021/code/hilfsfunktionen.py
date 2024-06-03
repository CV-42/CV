import numpy as np
import math

def linear_cutoff(steigung, maximum, x):
    """
    linear_cutoff(steigung, maximum, x)
    steigung = geradensteigung
    maximum = maximaler Wert, angenommen werden kann (Cutoff)
    x = Argument
    """
    return min(steigung*x, maximum)

def sigmoid_function(x):
    return 1/(1+ np.exp(-x))

def conti_sigmoid_cutoff(maximum, x):
    return (sigmoid_function(x)-0.5)*2*maximum

def find_ampel_zeiten_flex(incoming_cars_array, Duration, anzahl_der_cycles, Type='linear'):
    """
    find_ampel_zeiten(incoming_cars_array, Type='linear')
    incoming_cars_array = ZB [1,3,100,0]
    Duration = D aus Modell <===== WIRD NORMIERT MIT D/10 => 10 Ampelrotationen pro D
    anzahl_der_cycles wird gebraucht für D/anzahl_der_cycles
    Type='linear' oder 'quadratic' oder 'power4' oder 'exponential'
    gibt INTarray zurück
    """
    z = len(incoming_cars_array)
    return_array = np.zeros(z)
    if z==0:
        return np.ones(z).astype(int)
    else:
        if Type == 'linear':
            normierung = np.sum(incoming_cars_array)
            for i in range(z):
                return_array[i] = incoming_cars_array[i]/normierung
        if Type == 'quadratic':
            normierung = sum(np.square(incoming_cars_array))
            for i in range(z):
                print(incoming_cars_array[i])
                print(normierung)
                print(i)
                print("-----")
                return_array[i] = incoming_cars_array[i]*incoming_cars_array[i]/normierung
                print("----")
        if Type == 'power4':
            normierung = sum(np.square(np.square(incoming_cars_array)))
            for i in range(z):
                return_array[i] = incoming_cars_array[i]*incoming_cars_array[i]*incoming_cars_array[i]*incoming_cars_array[i]/normierung
        if Type == 'exponential':
            normierung = sum(np.exp(incoming_cars_array))
            for i in range(z):
                return_array[i] = np.exp(incoming_cars_array[i])/normierung
        
    return_array = return_array*Duration/anzahl_der_cycles
    return_array = np.ceil(return_array)
    return_array = return_array.astype(int)
    return return_array


def find_ampel_zeiten(incoming_cars_array, Duration, Type='linear'):
    """
    find_ampel_zeiten(incoming_cars_array, Type='linear')
    incoming_cars_array = ZB [1,3,100,0]
    Duration = D aus Modell <===== WIRD NORMIERT MIT D/10 => 10 Ampelrotationen pro D
    Type='linear' oder 'quadratic'
    gibt INTarray zurück
    """
    return find_ampel_zeiten_flex(incoming_cars_array, Duration, 10, Type)
