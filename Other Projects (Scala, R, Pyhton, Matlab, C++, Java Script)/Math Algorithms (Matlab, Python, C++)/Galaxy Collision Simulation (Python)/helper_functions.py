from numpy import *
def getAcc( pos, mass, G, softening ):
    """
    Calculate the acceleration on each particle due to Newton's Law 
    pos  is an N x 3 matrix of positions
    mass is an N x 1 vector of masses
    G is Newton's Gravitational constant
    softening is the softening length
    a is N x 3 matrix of accelerations
    """
    # positions r = [x,y,z] for all particles
    x, y, z = pos[:,0:1], pos[:,1:2], pos[:,2:3]
    N = len(pos[:,0])
   
    # matrix that stores all pairwise particle separations: r_j - r_i
    dx, dy, dz = x.T - x, y.T - y, z.T - z

    # matrix that stores 1/r^3 for all particle pairwise particle separations 
    # inv_r3 = (dx**2 + dy**2 + dz**2 + softening**2)
    inv_r3 = maximum(dx**2 + dy**2 + dz**2 , ones((N,N))*softening**2)
    inv_r3[inv_r3>0] = inv_r3[inv_r3>0]**(-1.5)

    ax, ay, az = G * (dx * inv_r3) @ mass, G * (dy * inv_r3) @ mass, G * (dz * inv_r3) @ mass
    
    # pack together the acceleration components
    a = hstack((ax,ay,az))

    return a
    
def getEnergy( pos, vel, mass, G ):
    """
    Get kinetic energy (KE) and potential energy (PE) of simulation
    pos is N x 3 matrix of positions
    vel is N x 3 matrix of velocities
    mass is an N x 1 vector of masses
    G is Newton's Gravitational constant
    KE is the kinetic energy of the system
    PE is the potential energy of the system
    """
    # Kinetic Energy:
    KE = 0.5 * sum(sum( mass * vel**2 ))


    # Potential Energy:

    # positions r = [x,y,z] for all particles
    x, y, z = pos[:,0:1], pos[:,1:2], pos[:,2:3]
   
    # matrix that stores all pairwise particle separations: r_j - r_i
    dx, dy, dz = x.T - x, y.T - y, z.T - z

    # matrix that stores 1/r for all particle pairwise particle separations 
    inv_r = sqrt(dx**2 + dy**2 + dz**2)
    inv_r[inv_r>0] = 1.0/inv_r[inv_r>0]

    # sum over upper triangle, to count each interaction only once
    PE = G * sum(sum(triu(-(mass*mass.T)*inv_r,1)))
    
    return KE, PE

from numpy import *

def merge(pos, mass, vel, galax_ids, new_galax_idx, merge_range):
    # glax_ids: contains for every star belonging to some galaxy number
    # new_galax_idx : if something is merged, it gets this new id 
    N = len(pos[:,0])
    # positions r = [x,y,z] for all particles
    x,y,z = pos[:,0:1], pos[:,1:2], pos[:,2:3]

    # matrix that stores all pairwise particle separations: r_j - r_i
    dx, dy, dz = x.T - x, y.T - y, z.T - z

    # matrix that stores distances 
    dists = (dx)**2 + (dy)**2 + (dz)**2

    # find ids of distance < merge_range
    h = transpose(where(dists < merge_range))
    # sort out doubled entries and self-entries:
    h =  h[ h[:,0] < h[:,1],: ]

    # array for only merging each particle once:
    merge_type = -ones(N)   # -1 for not merged, k >= 0 for new galaxy belonging
    new_pos = []
    new_mass = []
    new_vel = []
    new_ids = []

    for entry in range(len(h[:,0])):
        i,j = h[entry, :]
        if (merge_type[i] == -1) and (merge_type[j] == -1):
            if galax_ids[i] == galax_ids[j]:
                merge_type[i] = galax_ids[i]
                merge_type[j] = galax_ids[j]
                new_ids.append(galax_ids[i])
            else:
                merge_type[i] = new_galax_idx
                merge_type[j] = new_galax_idx
                new_ids.append(new_galax_idx)

            new_mass.append(mass[i]+mass[j])
            new_vel.append( (mass[i] * vel[i] + mass[j] * vel[j]) / new_mass[-1])
            new_pos.append((mass[i] * pos[i] + mass[j] * pos[j]) / new_mass[-1])
    
    if len(new_pos) > 0:
        # discard merged entries:
        pos = pos[merge_type == -1, :]
        vel = vel[merge_type == -1, :]
        mass = mass[merge_type == -1]
        galax_ids = galax_ids[merge_type == -1]
        # append new entries:
        pos = vstack((pos, new_pos))
        vel = vstack((vel, new_vel))
        mass = vstack((mass, new_mass))
        galax_ids = concatenate((galax_ids, new_ids))
    
    return pos, mass, vel, galax_ids