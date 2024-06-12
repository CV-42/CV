from numpy import *
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
import timeit
from initial_galaxies import *
from helper_functions import *
import os

# importing movie py libraries
#from moviepy.editor import VideoClip, ImageSequenceClip
#from moviepy.video.io.bindings import mplfig_to_npimage
"""
Create Your Own N-body Simulation (With Python)
Philip Mocz (2020) Princeton Univeristy, @PMocz

Simulate orbits of stars interacting due to gravity
Code calculates pairwise forces according to Newton's Law of Gravity
"""

def main():
    """ N-body simulation """
    
    # Simulation parameters
    N         = 42    # Number of particles
    t         = 0      # current time of the simulation
    tEnd      = 7   # time at which simulation ends
    dt        = 0.001   # timestep
    softening = 0.03    # softening length
    G         = 1.0    # Newton's Gravitational Constant
    plotRealTime = False # switch on for plotting as the simulation goes along
    merge_stars = False   # if every time step should check for close stars to merge them
    merge_range = 0.0005
    n_saves = 70      # how many frames to save into video
    
    # Generate Initial Conditions
    random.seed(17)            # set the random number generator seed
    
    # original initial conditions (all random)
    # mass = 20.0*np.ones((N,1))/N  # total mass of particles is 20
    # pos  = np.random.randn(N,3)   # randomly selected positions and velocities
    # vel  = np.random.randn(N,3)

    ## chose custom initial conditions:
    #pos, mass, vel = rotating_cloud(N)
    #pos, mass, vel = milky_way(N) 
    #pos, mass, vel = disk(N, G, softening)
    pos, mass, vel, galax_ids, merge_id = two_disks(N, G, softening, diam = 0.5)
    
    # Convert to Center-of-Mass frame
    vel -= mean(mass * vel,0) / mean(mass)
    
    # calculate initial gravitational accelerations
    acc = getAcc( pos, mass, G, softening )
    
    # number of timesteps
    Nt = int(ceil(tEnd/dt))
    
    # save energies, particle orbits for plotting trails
    save_points = linspace(0, Nt-1, n_saves, dtype=int)
    print("Following time points are going to be saved:")
    print(save_points)
    # t_all = arange(n_saves+1)*dt
    
    # # prep figure 3d
    # fig = plt.figure(figsize=(10,13), dpi=160)
    # grid = plt.GridSpec(1, 8, wspace=0.0, hspace=0.3)
    # ax1 = fig.add_subplot(grid[0,0:2], projection='3d')
    # ax2 = fig.add_subplot(grid[0,3:5], projection='3d')
    # ax3 = fig.add_subplot(grid[0,6:8], projection='3d')
    
    # prep figure 2d
    fig = plt.figure(figsize=(8,4), dpi=160)
    grid = plt.GridSpec(1, 8, wspace=0.0, hspace=0.3)
    ax1 = fig.add_subplot(grid[0,0:2])
    ax2 = fig.add_subplot(grid[0,3:5])
    ax3 = fig.add_subplot(grid[0,6:8])
    
    # Simulation Main Loop
    for i in range(Nt):
        # (1/2) kick
        vel += acc * dt/2.0
        
        # drift
        pos += vel * dt
        
        # merge stars that get close:
        if merge_stars == True:
          pos, mass, vel, galax_ids = merge(pos, mass, vel, merge_range = merge_range, galax_ids = galax_ids, new_galax_idx=2)

        # update accelerations
        acc = getAcc( pos, mass, G, softening )
        
        # (1/2) kick
        vel += acc * dt/2.0
        
        # update time
        t += dt
        
        ### plot in real time
        ## plot in 3d
        # if (plotRealTime and np.mod(i, 10)==0) or (i == Nt-1):
        #     plt.sca(ax1)
        #     plt.cla()
        #     ax1.scatter3D(pos[:,0], pos[:,1], pos[:,2], s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax1.set(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5,5),xlabel='X', ylabel='Y', zlabel='Z')
            
        #     plt.sca(ax2)
        #     plt.cla()
        #     ax2.scatter3D(pos[:,1], pos[:,2], pos[:,0], s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax2.set(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5,5), xlabel='Y', ylabel='Z', zlabel='X')
            
        #     plt.sca(ax3)
        #     plt.cla()
        #     ax3.scatter3D(pos[:,2], pos[:,0], pos[:,1], s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax3.set(xlim=(-5, 5), ylim=(-5, 5), zlim=(-5,5), xlabel='Z', ylabel='X', zlabel='Y')
            
        #     plt.pause(0.0000003)
        
        ## plot in 2d
        X, Y, Z = pos[:,0], pos[:,1], pos[:,2]  

        if i in save_points:
          print("Calculating step ",i," of ", save_points[-1])
          #plt.cla()

          X = pos[:,0]
          Y = pos[:,1]
          Z = pos[:,2]

          colors = ["blue", "red", "orange", "black"]
          color = [colors[i] for i in galax_ids]
          
          plt.sca(ax1)
          plt.cla()
          ax1.scatter(X, Y, s=1, c=color[:])
          ax1.set(xlim=(-5, 5), ylim=(-5, 5),xlabel='X', ylabel='Y')
          ax1.set_aspect('equal', 'box')

          plt.sca(ax2)
          plt.cla()
          ax2.scatter(Y, Z, s=1, c=color[:]) #,s=np.ones(N),color='blue'
          ax2.set(xlim=(-5, 5), ylim=(-5, 5), xlabel='Y', ylabel='Z')
          ax2.set_aspect('equal', 'box')

          plt.sca(ax3)
          plt.cla()
          ax3.scatter(X, Z, s=1, c=color[:]) #,s=np.ones(N),color='blue'
          ax3.set(xlim=(-5, 5), ylim=(-5, 5), xlabel='X', ylabel='Z')
          ax3.set_aspect('equal', 'box')

          # returning numpy image
          plt.savefig("Pictures/asdf"+str(i)+".png", format="png", orientation = 'Landscape')


          ###### Ende Bildspeichern
       
        # if (plotRealTime and i in linspace(0, Nt-1, 42, dtype=int)) or (i == Nt-1):
        #     plt.sca(ax1)
        #     plt.cla()
        #     ax1.scatter(X, Y, s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax1.set(xlim=(-5, 5), ylim=(-5, 5),xlabel='X', ylabel='Y')
        #     ax1.set_aspect('equal', 'box')
            
        #     plt.sca(ax2)
        #     plt.cla()
        #     ax2.scatter(Y, Z, s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax2.set(xlim=(-5, 5), ylim=(-5, 5), xlabel='Y', ylabel='Z')
        #     ax2.set_aspect('equal', 'box')
            
        #     plt.sca(ax3)
        #     plt.cla()
        #     ax3.scatter(X, Z, s=1, c=color[:]) #,s=np.ones(N),color='blue'
        #     ax3.set(xlim=(-5, 5), ylim=(-5, 5), xlabel='X', ylabel='Z')
        #     ax3.set_aspect('equal', 'box')
            
        #     plt.pause(0.0000003)
  
  ############ Create Gif:

    filenames = ["Pictures/asdf"+str(k)+".png" for k in save_points]
    # print(filenames)
    # animation = ImageSequenceClip(filenames, fps=1/5)
    # animation.write_videofile("a.webm")

    import imageio.v2 as imageio
    images = []
    for filename in filenames:
        images.append(imageio.imread(filename))
    imageio.mimwrite('movie.gif', images)

    return 0
    
  
if __name__== "__main__":

    for file in os.listdir('Pictures/'):
        if file.endswith('.png'):
            os.remove('Pictures/' + file) 

    start = timeit.default_timer()
    main()    
    stop = timeit.default_timer()
    print('Time : ',stop - start)


