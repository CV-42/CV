T = int(input())

for t in range(T):
    [N, D, C, M] = [int(s) for s in input().split(" ")]
    S = [s for s in input()]
    # print(S)
    anzHungrigeHunde = 0
    for tier in S:
        if tier == "D":
            anzHungrigeHunde += 1
    # print(anzHungrigeHunde)
    mgl = anzHungrigeHunde <= D
    i = 0
    while (i <= N-1) and mgl and (anzHungrigeHunde >=1):
        if S[i] == "D":
            # if D >= 1:
            #     D -= 1
            C += M
            anzHungrigeHunde -= 1
            # else:
            # mgl = False
        else:
            if C>= 1:
                C -= 1
            else:
                mgl = False
        i += 1

    if mgl:
        print("Case #" + str(t+1) + ": " + "YES")
    else:
        print("Case #" + str(t+1) + ": " + "NO")