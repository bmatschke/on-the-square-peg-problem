'''
The following script shows that the (up to symmetry) two inscribed rectangles
in an ellipse get in some natural configuration-space/test-map scheme
the opposite preimage orientation.
Thus the standard topological method to prove the 
rectangular peg problem (inscribed rectangle problem) fails.
'''

a,r,t1,t2,t3,t4 = var('a r t1 t2 t3 t4')
ts = [t1,t2,t3,t4]

specialize = {t1:0, t2:0, t3:0, t4:0}

#Consider the ellipse
#a = 1/2 
gamma(t) = (cos(t),a*sin(t))

#Inscribed rectangles of aspect ratio r:
a1 = arctan((1/r)/a)
a2 = pi-arctan(r/a)
R1t = [gamma(t1+a1),gamma(t2+pi-a1),gamma(t3+pi+a1),gamma(t4-a1)]
R1 = [tuple(c.subs(specialize) for c in P) for P in R1t]
R2t = [gamma(t1+a2),gamma(t2-a2),gamma(t3+pi+a2),gamma(t4+pi-a2)]
R2 = [tuple(c.subs(specialize) for c in P) for P in R2t]

'''
#The following plots gamma and the inscribed squares,
#assuming a and r were specialized at the beginning:
G = parametric_plot(gamma,(t,0,2*pi))
for i,P in enumerate(R1):
    G += text("R1_%s"%(i,),P)
for i,P in enumerate(R2):
    G += text("R2_%s"%(i,),P)
#G.show()
'''

def normSq(v):
    return sum(vi^2 for vi in v)

def testmap(R):
    #We use a slightly different test-map for rectangles here as in the paper.
    #The following is computationally easier.
    #Both test-maps are around r-rectangles the same up to a coordinate transformation.
    #Hence for the sake of orientations, nothing changes.
    
    P0,P1,P2,P3 = [vector(P) for P in R]
    v = (P0+P2)/2 - (P1+P3)/2
    l = normSq(P0-P2) - normSq(P1-P3)
    a = normSq(P0-P1) - normSq(P1-P2)
    return list(v) + [l,a]
    
T1 = testmap(R1t)
T2 = testmap(R2t)

M1 = matrix([[T.derivative(ti).subs(specialize) for ti in ts] for T in T1])
M2 = matrix([[T.derivative(ti).subs(specialize) for ti in ts] for T in T2])

detM1M2 = det(M1)*det(M2)
print("detM1M2:",detM1M2.factor())
#detM1M2: -1024*(a^2 + 1)^2*(a + 1)^2*(a - 1)^2*a^8*r^6/((a^2*r^2 + 1)^3*(a^2 + r^2)^3)
#
#Thus, detM1M2 is negative unless |a| = 1 (i.e. when gamma is a circle).
#Thus det(M1) and det(M2) have opposite signs.
#Thus the two inscribed rectangles R1 and R2 have opposite preimage orientations.
