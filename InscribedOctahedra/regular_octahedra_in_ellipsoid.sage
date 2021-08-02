'''
The following computes the set (modulo S^1-symmetry) of inscribed 
regular octahedra in the ellipsoid {x^2 + y^2 + 2*z^2 = 8}.
'''

def flat_sphere_polynomial(point):
    return point[0]^2 + point[1]^2 + 2*point[2]^2 - 8

#We would like to define R as follows, but it leads to PariError in I.variety(RR):
#R.<mx,my,mz,rx,ry,rz,sx,sy,sz> = QQ[]
#The following different variable orders don't seem to solve the issue:
#R.<mz,my,mx,rz,ry,rx,sz,sy,sx> = QQ[]
#R.<sz,sy,sx,rz,ry,rx,mz,my,mx> = QQ[]
#Thus we simply take standard variable names:
R = PolynomialRing(QQ,12,'x')
#... and put:
mx,my,mz,rx,ry,rz,sx,sy,sz,tx,ty,tz = R.gens()

RRprec = RealField(1000)

m = vector((mx,my,mz))
r = vector((rx,ry,rz))
s = vector((sx,sy,sz))
t = vector((tx,ty,tz))

def normSq(v):
    return sum(vi^2 for vi in v)

equations = []

#Require r,s,t to be pairwise orthogonal and of equal norm:
equations.append(normSq(s)-normSq(r))
equations.append(normSq(t)-normSq(r))
equations.append(r*s)
equations.append(r*t)
equations.append(s*t)

#Mod out the S^1-symmetry:
equations.append(ry)

#Require the vertices of the regular octahedron to lie on the ellipsoid: 
points = [m+r,m-r,m+s,m-s,m+t,m-t]
for point in points:
    equations.append(flat_sphere_polynomial(point))
    
I_0 = R.ideal(equations)
print("I_0:",I_0)
 
#Remove degenerate inscribed regular octahedra:
I_degenerate = R.ideal(normSq(r))
I = I_0.saturation(I_degenerate)[0]

if I.dimension() == 0:
    V = I.variety(RR)
    print("V:",V)
    print("len(V):",len(V))
    O = V[0]
    for xi, coord in O.items():
        print(xi,":",coord.algdep(4),",",coord)
        
    #We can check by hand that the numerically obtained algebraic expression of the coordinates indeed give a correct answer.
