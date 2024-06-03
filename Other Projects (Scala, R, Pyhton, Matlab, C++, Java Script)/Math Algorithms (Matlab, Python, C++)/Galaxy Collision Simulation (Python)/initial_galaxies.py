from numpy import *
from scipy.spatial.transform import Rotation

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
   
    # matrix that stores all pairwise particle separations: r_j - r_i
    dx, dy, dz = x.T - x, y.T - y, z.T - z

    # matrix that stores 1/r^3 for all particle pairwise particle separations 
    inv_r3 = (dx**2 + dy**2 + dz**2 + softening**2)
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

def rotating_cloud(N, e = array([0,0,1])):
    ### N = number of stars
    ### e = rotation axis
    pos = random.randn(N,3)
    mass = random.standard_gamma(shape = 0.5, size = (N,1))
    vel = zeros((N,3))
    for i in range(N):
        vel[i,:] = cross(e, pos[i,:])
    return pos, mass, vel

def disk(N, G, softening, total_mass = 1, e = array((0,0,1)), diam = 2):
    # G = Gravitational constant (for balancing velocities)
    d = - cross(e, array((1,0,0)))
    alpha = arccos(dot(d,e))
    rot = Rotation.from_rotvec(alpha * d)
    a,b = rot.apply(array((0,1,0))), rot.apply(array((0,0,1)))
    pos2 = random.normal(loc = 0.0, scale = diam / 4, size = (N,2))
    pos = zeros((N,3))
    for i in range(N):
        pos[i,:] = a*pos2[i,0] + b*pos2[i,1]
        
    pos[0,:] = zeros((1,3))

    # equal mass for all:
    mass = ones((N,1)) 
    # mass[0] = sum(mass)
    mass = mass / sum(mass) * total_mass
    # mass = np.ones((N,1)) / total_mass

    # calculate velocity to cancel out gravitation --> stable galaxy!
    acc = getAcc(pos, mass, G, softening)
    acc = linalg.norm(acc, axis = 1)
    mid = mean(pos, 0)
    r = linalg.norm(pos - mid, axis = 1)
    v_norm, v = sqrt(r * acc), cross(pos - mid, e)
    v[v_norm != 0] = v[v_norm != 0] / linalg.norm(v[v_norm != 0], axis = 1)[:, None] ## Durch Null geteilt!!! Ändern!!!
    vel = v * v_norm[:, None]


    return pos, mass, vel

def two_disks(N, G, softening, diam = 0.6):
    N1 = int(N/2)
    N2 = N - N1
    pos1, mass1, vel1 = disk(N1, G, softening, diam = diam)
    pos2, mass2, vel2 = disk(N2, G, softening, e = array((0,0,1)), diam = diam)
    D1 = zeros((N1,3))
    D1[:,0] = -1
    D1[:,1] = 1
    pos1 += diam*D1
    D2 = zeros((N2,3))
    D2[:,0] = 1
    D2[:,1] = -1
    pos2 += diam*D2
    
    vel1 -= D1/4
    
    pos = vstack((pos1,pos2))
    mass = vstack((mass1, mass2))
    vel = vstack((vel1,vel2))

    galax_ids = concatenate((full(N1,0), full(N2,1)))
    merge_id = 2
    return pos, mass, vel, galax_ids, merge_id

def two_milkies(N, bar_length = 0.5, bar_thickness = 0.2, e = array((0,0,1)), d = array((1,0,0)), diam = 2, arm_length = 2, ratio  = 2):
    N1 = int(N/2)
    N2 = N - N1
    pos1, mass1, vel1 = milky_way(N1)
    pos2, mass2, vel2 = milky_way(N2)
    D1 = zeros((N1,3))
    D1[:,0] = -1
    D1[:,1] = 1
    pos1 += diam*D1
    D2 = zeros((N2,3))
    D2[:,0] = 1
    D2[:,1] = -1
    pos2 += diam*D2
    pos = vstack((pos1,pos2))
    mass = vstack((mass1, mass2))
    vel = vstack((vel1,vel2))
    return pos, mass, vel


def milky_way(N, bar_length = 0.5, bar_thickness = 0.01, e = array((0,0,1)), d = array((1,0,0)), diam = 2, mass_ratio  = 2, total_mass = 3):
    ### N = number of stars
    ### bar_length = length of inner bar
    ### bar thickness = thickness of inner bar
    ### e = rotation axis
    ### diam = diameter of all (bar+arms)
    ### arm_length
    ### mass_ratio = number stars in bar / number stars in arms
    ### d = direction of the bar
    ### total_mass = total mass of galaxy
    N_arm = int(N / (1+mass_ratio) * mass_ratio / 2) # divide by 2 because of two arms
    N_bar = N - 2 * N_arm

    # bar is like an ellipse:
    bar = random.rand(N_bar,3) + random.randn(N_bar,3) / 5
    stretch  = bar_thickness * (eye(3) + (bar_length / bar_thickness -1) * tensordot(d,d, axes = 0))
    bar = bar @ stretch

    # arms parametrized by angle
    ang = abs(random.laplace(scale = 2, size = (N_arm,1)))
    arm1 = zeros((N_arm, 3))
    for i in range(N_arm):
        rot = Rotation.from_rotvec(ang[i] * e)
        arm1[i,:] = rot.apply(d) * (bar_length + (diam-bar_length) *  abs(ang[i] / (2*pi)))
    arm2 = - arm1
    
    pos = vstack((bar, arm1, arm2))
    vel = cross(pos, e) * 4
    mass = random.standard_gamma(shape = 0.5, size = (N,1))
    mass = mass / sum(mass) * total_mass
    return pos, mass, vel
