import numpy as np

T = int(input())

for t in range(T):
    [N, A, B, C] = [int(s) for s in input().split(" ")]
    X = np.zeros([N])
    moeglich = (A >= C and B >= C and N+C >= A + B and (A>1 or B>1))
    if N == 1:
        if (A==B) and (A==C):
            moeglich = True
            X[0] = 1
        else:
            moeglich = False
    if N == 2 and moeglich:
        if A < B:
            X[0:2] = 2, 1
        elif A > B:
            X[0:2] = 1, 2
        else:
            X[0:2] = 1, 1
    if moeglich and N>2:
        if A==B and B==C:
            l = C // 2
            r = C - l
            X[0:N] = 1
            X[0 : l] = N
            X[(N - (r - 1) -1) : N] = N
        elif (B>C) or (A+B == N+C):
            X[0 : (N)] = 1
            X[0:(A)] = 3
            X[0:(A-C)] = 2
            X[(N-B+C + 1 - 1) : (N)] = 2
        else:
            X[0: (N)] = 1
            X[(N-B + 1 - 1) : (N)] = 3
            X[(N - B + C + 1 - 1) : (N)] = 2
            X[0:(A-C)] = 2
    if moeglich:
        X = X.astype(int)
        X = X.astype(str)
        print("Case #" + str(t+1) + ": " + " ".join(X))
    else:
        print("Case #" + str(t+1) + ": " + "IMPOSSIBLE")