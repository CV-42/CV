### Functions for the first supplementary exercise

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def scheme(u, dt, eps, q = 1, typeGrad = "L2", typeDiscr = "SemiImpl"):
    ### Contains 4 schemes for the 1D phase field crystal model
    ### The choise between the 4 schemes has to be done using "typeGrad" and "typeDiscr"

    N = len(u)
    # Transfering everything into Fourier space:
    u_hat = np.fft.fft(u)
    u_hat_3 = np.fft.fft(u**3)
    u_hat_new = np.zeros_like(u_hat)
    k = np.fft.fftfreq(N, 1/N)
    # Approximation of Time Step with one of the 4 schemes:
    if (typeGrad == "L2") & (typeDiscr == "Expl"):
        fak = (eps - q**4) * u_hat - u_hat_3 + 2 * q**4 * k**2 * u_hat - q**4 * k**4 * u_hat
        u_hat_new = u_hat + dt * fak
    elif (typeGrad == "L2") & (typeDiscr == "SemiImpl"):
        fak = 1 + dt * (q**4 - eps - 2 * q**4 * k**2 + q**4 * k**4)
        u_hat_new = 1 / fak * (u_hat - dt * u_hat_3)
    elif (typeGrad == "HMinus1") & (typeDiscr == "Expl"):
        fak = (eps - q**4) * k**2 * u_hat - k**2 * u_hat_3 - 2 * q**4 * k**2 * u_hat - q**4 * k**6 * u_hat
        u_hat_new = u_hat + dt * fak
    elif (typeGrad == "HMinus1") & (typeDiscr == "SemiImpl"):
        fak = 1 + dt * (q**6 * k**2 - eps * q**2 * k**2 - 2 * q**6 * k**4 + q**6 * k**6)
        u_hat_new = 1 / fak * (u_hat - dt * q**2 * k**2 * u_hat_3)
    else:
        print("Unknwon specifications for algorithm!")
    return np.real(np.fft.ifft(u_hat_new))



def solve_PDE(u0, dt, tMax, eps, q = 1, typeGrad = "L2", typeDiscr = "SemiImpl"):
    ### Applies the time step implemented in "scheme" a lot of times

    # preparations:
    u_list = [u0]
    times = np.arange(0, tMax, dt)

    # time stepping:
    for t in times:
        u_list += [scheme(u_list[-1], dt, eps, q, typeGrad = typeGrad, typeDiscr = typeDiscr)]

    # returning the whole evolution:
    return times, u_list

def part_c(typeGrad = "L2", initFun = 0):
    # possibilities:    typeGrad in ["L2","HMinus1"]
    #                   initFun in [0, 1] for "sin" or "random"
    # Choosing the model:
    typeDiscr = ["SemiImpl", "Expl"][0]  # Semi-Implicit is much better!
    eps = 1
    q = 1 # ! The domains are normalized to the case of q = 1 ! Still, the influence of q is considered in the equations.
    
    # Discretization (x)
    M = 2**5
    N = 2*M
    h = 2*np.pi/N
    x = h*np.arange(0,N)

    # Discretization (t)
    dt = 0.01
    tMax = 15

    #Initial Condition and parameters (Choose one of them!)
    np.random.seed(42)
    u_ini_function = [lambda x: np.sin(x) + np.cos(6*x) / 10 + 3, \
        lambda x: np.random.uniform(-1,1,len(x))][initFun]
    u_ini = u_ini_function(x)

    # Calculations: 
    print("Starting the calcultions...")
    zeiten, u_list = solve_PDE(u_ini, dt, tMax, eps, q, typeGrad = typeGrad, typeDiscr = typeDiscr)
    print(" ... calculations done.")

    # Plotting:
    fig, ax = plt.subplots()
    fig.suptitle("asdf")
    line, = ax.plot(x, u_ini)
    frames = (np.linspace(0, np.sqrt(len(zeiten), ), 200)).astype(int) ** 2

    def init():
        line.set_ydata([np.nan] * len(x))
        ax.set_xlim([0, 2 * np.pi])
        x_min = min(x)
        x_max = max(x)
        y_min = min([val for sublist in u_list for val in sublist])
        y_max = max([val for sublist in u_list for val in sublist])
        ax.set_ylim([y_min - 0.1, y_max + 0.1])
        ax.set_xlim([x_min - 0.1, x_max + 0.1])
        return line,

    def animate(i):
        line.set_ydata(u_list[i])  # update the data.
        fig.suptitle("Step " + str(i) + " From " + str(max(frames)))
        return line,

    ani = animation.FuncAnimation(
        fig, animate, frames = frames, init_func=init, interval=2, blit=False)

    # To save the animation, use e.g.
    #
    # file_name = "Gradient type " + typeGrad + ", Method " + typeDiscr+ ", dt "+ str(dt) + ", tMax "+str(tMax) + ", eps " + str(eps) " .mp4"
    # ani.save()
    #
    # or (better)
    #
    # filename = "Gradient type " + typeGrad + ", Method " + typeDiscr+ ", dt "+ str(dt) + ", tMax "+str(tMax) + ", eps " + str(eps) + " .mp4"
    # writer = animation.FFMpegWriter(
    #     fps=20, bitrate=1800)
    # ani.save(filename, writer=writer)
    # print("Saving done.")

    plt.show()
    print(max(np.abs(u_list[-1])))

def part_d_part_1():
    # Choosing the model:
    typeGrad_list = ["L2","HMinus1"]
    typeDiscr = ["SemiImpl", "Expl"][0] # Semi-Implicit is better!
    eps_list = np.linspace(-1,1,5)
    q = 1 # ! The domains are normalized to the case of q = 1 ! Still, the influence of q is considered in the equations.
    
    # Discretization (x)
    M = 2**5
    N = 2*M
    h = 2*np.pi/N
    x = h*np.arange(0,N)

    # Discretization (t)
    dt = 0.001 # 0.01 is enough for most cases
    tMax = 100  # at tMax = 20 there's normally no change anymore

    #Initial Condition and parameters
    np.random.seed(42)
    u_ini_function_list = [lambda x: np.sin(x) + np.cos(6*x) / 10 + 3, \
        lambda x: np.random.uniform(-1,1,len(x))]
    

    # Calculations and Plotting: 
    print("Starting the calcultions...")
    for i in range(len(u_ini_function_list)):
        # This loop is for two figures depending on the initial condition
        print("-----------------------")
        print("i - Round ",i + 1," of 2")
        u_ini_function = u_ini_function_list[i]
        u_ini = u_ini_function(x)
        fig = plt.figure(figsize = [30, 20])

        ax = fig.add_subplot(2,len(eps_list)+1, 1)
        ax.plot(x, u_ini)
        ax.set_title("u_ini")
        ax = fig.add_subplot(2,len(eps_list)+1, len(eps_list)+2)
        ax.plot(x, u_ini)
        ax.set_title("u_ini")
        for j in range(2):
            # This loop is for the two lines per figure depending on the Gradient type
            print("j - Sub-Round ", j + 1, " of 2")
            typeGrad = typeGrad_list[j]
            for k in range(len(eps_list)):
                # This loop is for the columns of each figure, depending on the eps_list
                print("k - Sub-Sub-Round ", k + 1, "of ", len(eps_list))
                eps = eps_list[k]
                zeiten, u_list = solve_PDE(u_ini, dt, tMax, eps, q, typeGrad = typeGrad, typeDiscr = typeDiscr)
                ax = fig.add_subplot(2,len(eps_list)+1,  j * (len(eps_list) + 1) + k + 2)
                ax.plot(x, u_list[-1], label = "eps = " + str(np.round(eps,2)) + ", Gradient = " + typeGrad)
                ax.legend()
        # Saving the figure:
        plt.savefig("u_ini_function[" + str(i) + "].png")
        plt.close()
    print(" ... calculations done.")
