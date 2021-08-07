'''
The code is an approach to the inscribed rectangle problem.

The inscribed rectangle problems asks whether any (smooth or piecewise linear)
Jordan curve contains the four vertices of a rectangle with given aspect ratio.
In my thesis I showed that if a (generic) such curve does not inscribe a
rectangle of some aspect ratio, then there must exist a Z/4-invariant loop
in the set of inscribed rectangles (or arbitrary aspect ratio).
But is such a Z/4 invariant loop even possible? This needs to be the case
_generically_, which means that at each point of the loop, the test-map
measuring inscribed squares must be transversal to the test-space.
This translates into a determinant being non-zero, at each point of the loop.

This code contains the following two separate approaches:
1.) We construct a curve and determine its 1-dimensional components of
inscribed rectangles.
2.) We construct a Z/4-invariant loop in the set of planar rectangles in 
such a way that the trace of a single vertex is a Jordan curve.

Author: Benjamin Matschke

License: Creative Commons 4.0 BY-NC.

To the code:
The following parametrizes a Z/4-invariant loop in the set of planar rectangles.
The parameter is "t".
Each rectangle gets parametrized by
- mx,my: midpoint
- r: radius of circumcircle
- theta-rho and theta+rho: the two angles of MP1,MP2 to the x-axis, respectively,
   where MP1 is the vector from the midpoint to the first vertex of the rectanlge,
   and MP2 is the vector from the midpoint to the second vertex of the rectanlge.
These five variables determine the x and y coordinates of the four vertices
P1,P2,P3,P4.
'''

RIF = RealIntervalField(53);
#RIF = RealIntervalField(1000);

t = var("t");

s = sin(2*pi*t);
c = cos(2*pi*t);
s2 = s(2*t);
c2 = c(2*t);
s4 = s(4*t);
c4 = c(4*t);
s6 = s(6*t);
c6 = c(6*t);

#r must have period 1/4:
r = 10+1*s4;

#m = (mx,my) must have period 1/4:
mx = 1*s4(t+0.1);
my = 1*c4(t+0.1);

#theta-t must have period 1/4:
theta = t + 0.01*s4;

#rho-1/8 must change sign under halfperiod 1/4:
rho = 1/8 + 0.01*(s2);

alpha = theta - rho;
beta = theta + rho;

x1 = mx + r*c(alpha);
y1 = my + r*s(alpha);
P1 = (x1,y1);
x2 = mx + r*c(beta);
y2 = my + r*s(beta);
P2 = (x2,y2);
x3 = mx - r*c(alpha);
y3 = my - r*s(alpha);
P3 = (x3,y3);
x4 = mx - r*c(beta);
y4 = my - r*s(beta);
P4 = (x4,y4);

#Plotting P1,...,P4:
G = parametric_plot(P1,(t,0,1));
G += parametric_plot(P2,(t,0,1));
G += parametric_plot(P3,(t,0,1));
G += parametric_plot(P4,(t,0,1));
#G.show();

#TODO:
#Compute discretization of gamma.
#Compute the set of degenerate rectangles (critical points of the distance function).
#Compute 1-dimensional manifold of inscribed rectangles with degenerate rectangles as boundary (and hence starting point of computation).
#Check whether there is a "skinny-to-fat" component.

class Point:
	def __init__(self,xy,index):
		self.xy = xy;
		self.index = index;
		
	def __str__(self):
		return "("+str(self.xy[0])+","+str(self.xy[1])+")";

class Edge:
	def __init__(self,P1,P2):
		self.P1 = P1;
		self.P2 = P2;
		self.direction = P2.xy-P1.xy;
		self.normal = vector((-self.direction[1],self.direction[0]));
		self.normSq = self.direction * self.direction;
		self.norm = sqrt(self.normSq);
		
	def __str__(self):
		return "E"+str(self.index());
		
	def __eq__(self, other):
		if not isinstance(other, self.__class__):
			return False;
		return self.index() == other.index();
			
	def containsPoint(self,P):
		return P==self.P1 or P==self.P2;
		
	def index(self):
		return self.P1.index;
		
	def coordinateOfVector(self,v):
		return (v-self.P1.xy) * self.direction / self.normSq;
		
	def coordinateOfPoint(self,P):
		return self.coordinateOfVector(P.xy);
		
	def vectorOnWhichSide(self,v):
		return column_matrix([self.direction,v-self.P1.xy]).det().sign();
	
	def pointOnWhichSide(self,P):
		return self.vectorOnWhichSide(P.xy);
		
	def doesEdgeEStriclyCrossSidesOfSelf(self,E):
		return self.pointOnWhichSide(E.P1)*self.pointOnWhichSide(E.P2) == -1;
		
	def intersectsEdgeInInterior(self,E):
		return self.doesEdgeEStriclyCrossSidesOfSelf(E) and E.doesEdgeEStriclyCrossSidesOfSelf(self);

	def doesEdgeEWeaklyCrossSidesOfSelf(self,E):
		return self.pointOnWhichSide(E.P1)*self.pointOnWhichSide(E.P2) != 1;
		
	def intersectsEdge(self,E):
		return self.doesEdgeEWeaklyCrossSidesOfSelf(E) and E.doesEdgeEWeaklyCrossSidesOfSelf(self);
	
	def previousEdge(self):
		return self.P1.E1;
		
	def nextEdge(self):
		return self.P2.E2;
	
class Rectangle:
	def __init__(self,E1,E2,E3,E4,t1,t2,t3,t4,cyclicRelabellings=0):
		#Relabel cyclically to make it canonically labelled:
		self.cyclicRelabellings = cyclicRelabellings;
		while E1.index() >= E4.index(): 
			E1,E2,E3,E4 = E2,E3,E4,E1;
			t1,t2,t3,t4 = t2,t3,t4,t1;
			self.cyclicRelabellings += 1;
		self.E1 = E1;
		self.E2 = E2;
		self.E3 = E3;
		self.E4 = E4;
		self.t1 = t1;
		self.t2 = t2;
		self.t3 = t3;
		self.t4 = t4;
		self.P1 = E1.P1.xy + t1*E1.direction;
		self.P2 = E2.P1.xy + t2*E2.direction;
		self.P3 = E3.P1.xy + t3*E3.direction;
		self.P4 = E4.P1.xy + t4*E4.direction;
		self.a = (self.P2-self.P1).norm();
		self.b = (self.P4-self.P1).norm();

	def __str__(self):
		#return "("+str(self.E1.index())+","+str(self.E2.index())+","+str(self.E3.index())+","+str(self.E4.index())+")";
		#return "("+str(self.E1.index())+","+str(self.E2.index())+","+str(self.E3.index())+","+str(self.E4.index())+"|"+str(RR(self.t1))+","+str(RR(self.t2))+","+str(RR(self.t3))+","+str(RR(self.t4))+")";
		return "("+str(self.E1.index())+","+str(self.E2.index())+","+str(self.E3.index())+","+str(self.E4.index())+"|"+str(self.t1)+","+str(self.t2)+","+str(self.t3)+","+str(self.t4)+")";
		
	def __eq__(self, other):
		#Return Trye if they POSSIBLY CAN be equal.
		if not isinstance(other, self.__class__):
			return False;
		if self.E1 != other.E1 or self.E2 != other.E2 or self.E3 != other.E3 or self.E4 != other.E4:
			return False;
		if self.t1 != other.t1 or self.t2 != other.t2 or self.t3 != other.t3 or self.t4 != other.t4:
			return False;
		return True;

	def edges(self):
		return (self.E1,self.E2,self.E3,self.E4);
		
	def firstEdge(self):
		return self.edges()[(-self.cyclicRelabellings) % 4];	

	def isSkinny(self):
		if self.E1 == self.E2 and self.t1.overlaps(self.t2):
			return True;
		if self.E1.nextEdge() == self.E2 and (self.t1-1).contains_zero() and self.t2.contains_zero():
			return True;
		return False;		

	def isFat(self):
		if self.E2 == self.E3 and self.t2.overlaps(self.t3):
			return True;
		if self.E2.nextEdge() == self.E3 and self.t2.overlaps(RIF(1)) and self.t3.contains_zero():
			return True;
		return False;
		
	def isDegenerate(self):
		return self.isSkinny() or self.isFat();
	
	def reparametrizedRectangle(self):
		#If the rectangle has a vertex that is at the end-point of an edge,
		#then it is at the same time the end-point of an adjacent edge.
		#So we get the same rectangle, but with a different parametrization:
		E1 = self.E1;
		E2 = self.E2;
		E3 = self.E3;
		E4 = self.E4;
		t1 = self.t1;
		t2 = self.t2;
		t3 = self.t3;
		t4 = self.t4;
		if self.t1.overlaps(RIF(0)) and not (self.t4.overlaps(RIF(1)) and E4==self.E1.previousEdge()):
			return Rectangle(E1.previousEdge(),E2,E3,E4,RIF(1),t2,t3,t4,self.cyclicRelabellings);
		if self.t2.overlaps(RIF(0)) and not (self.t1.overlaps(RIF(1)) and E1==self.E2.previousEdge()):
			return Rectangle(E1,E2.previousEdge(),E3,E4,t1,RIF(1),t3,t4,self.cyclicRelabellings);
		if self.t3.overlaps(RIF(0)) and not (self.t2.overlaps(RIF(1)) and E2==self.E3.previousEdge()):
			return Rectangle(E1,E2,E3.previousEdge(),E4,t1,t2,RIF(1),t4,self.cyclicRelabellings);
		if self.t4.overlaps(RIF(0)) and not (self.t3.overlaps(RIF(1)) and E3==self.E4.previousEdge()):
			return Rectangle(E1,E2,E3,E4.previousEdge(),t1,t2,t3,RIF(1),self.cyclicRelabellings);
		if self.t1.overlaps(RIF(1)) and not (self.t2.overlaps(RIF(0)) and E2==self.E1.nextEdge()):
			return Rectangle(E1.nextEdge(),E2,E3,E4,RIF(0),t2,t3,t4,self.cyclicRelabellings);
		if self.t2.overlaps(RIF(1)) and not (self.t3.overlaps(RIF(0)) and E3==self.E2.nextEdge()):
			return Rectangle(E1,E2.nextEdge(),E3,E4,t1,RIF(0),t3,t4,self.cyclicRelabellings);
		if self.t3.overlaps(RIF(1)) and not (self.t4.overlaps(RIF(0)) and E4==self.E3.nextEdge()):
			return Rectangle(E1,E2,E3.nextEdge(),E4,t1,t2,RIF(0),t4,self.cyclicRelabellings);
		if self.t4.overlaps(RIF(1)) and not (self.t1.overlaps(RIF(0)) and E1==self.E4.nextEdge()):
			return Rectangle(E1,E2,E3,E4.nextEdge(),t1,t2,t3,RIF(0),self.cyclicRelabellings);
		return None;
		
	def aspectRatio(self):
		if self.cyclicRelabellings % 2 == 0:
			return RIF(self.a/self.b);
		else:
			return RIF(self.b/self.a);
		
	def aspectRatioSmaller1(self):
		if self.a < self.b:
			return RIF(self.a/self.b);
		else:
			return RIF(self.b/self.a);
		
	def edgeIndices(self):
		return (self.E1.index(),self.E2.index(),self.E3.index(),self.E4.index());
	
class Curve:
	def __init__(self,pointVectors=None,n=None,P=None,t=None):
		self.parametrization = P;
		self.parametrizationX = P[0];
		self.parametrizationY = P[1];
		self.t = t;
		if P!=None:
			pointVectors = [];
			for i in range(n):
				#p = vector(P).apply_map(lambda param: RR(param(t=i/n)).simplest_rational());
				p = vector(P).apply_map(lambda param: RIF(param(t=i/n)));
				pointVectors.append(p);		
		if pointVectors!=None:
			self.n = len(pointVectors);
			self.points = [];
			for i in range(self.n):
				self.points.append(Point(pointVectors[i],i));		
			
		#Set up edges:
		self.edges = [];
		for i in range(self.n):
			j = (i+1) % n;
			E = Edge(self.points[i],self.points[j]);
			self.edges.append(E);
			self.points[i].E2 = E;
			self.points[j].E1 = E;		
		
		self.computeDegenerateRectangles();
		
	def show(self):
		g = Graphics();
		for p in self.points:
			i = self.points.index(p);
			radius = 1;
			m = (p.xy[0].center(),p.xy[1].center());
			c = circle(m,radius);
			g += c;
			g += text(str(i),m,fontsize = max(16,min(4,radius*g.SHOW_OPTIONS['dpi'])));
		for e in self.edges:
			m1 = (e.P1.xy[0].center(),e.P1.xy[1].center());
			m2 = (e.P2.xy[0].center(),e.P2.xy[1].center());
			a = arrow(m1,m2);
			#g += a;
		g.show(axes=False);

	def computeDegenerateRectangles(self):
		#Outputs possibly more in case of numerical imprecisions, but no less.
		result = [];
		
		#TODO: Should restrict to only the ones that lie cyclically on the curve, or not?!
		
		#Degenerate rectangles between a point and an edge:
		for P in self.points:
			for E in self.edges:
				if P != E.P1 and P != E.P2:
					coor = E.coordinateOfPoint(P);
					if coor.overlaps(RIF(0,1)):
						#Now, orthogonal projection of P on line through E lands in E.
						if (P.E1.direction*E.normal).contains_zero():
							print E1,E;
							raise Exception("Curve is not generic, as two edges are parallel!");
						if (P.E2.direction*E.normal).contains_zero():
							print E2,E;
							raise Exception("Curve is not generic, as two edges are parallel!");
						if not (P.E1.direction*E.normal) * (P.E2.direction*E.normal) >= 0:
							#Possible degenerate rectangle found:
							R = Rectangle(E,E,P.E1,P.E2,coor,coor,RIF(1),RIF(0));
							result.append(R);
		
		#Degenerate rectangles between two points:			
		for i in range(self.n-1):
			for j in range(i+1,self.n):
				P = self.points[i];
				Q = self.points[j];
				s = P.xy - Q.xy;
				if not (P.E1.direction*s) * (P.E2.direction*s) >= 0:
					if not (Q.E1.direction*s) * (Q.E2.direction*s) >= 0:
						#Degenerate rectangle found:
						R = Rectangle(P.E1,P.E2,Q.E1,Q.E2,RIF(1),RIF(0),RIF(1),RIF(0));
						result.append(R);
		
		return result;
		
	def isSimpleCurve(self):
		return self.selfIntersections() != [];
		
	def intersectingEdgePairs(self):
		result = [];		
		for i in range(self.n):
			for j in range(i+2,n):
				if i!=j+1-n:
					Ei = self.edges[i];
					Ej = self.edges[j];
					if Ei.intersectsEdge(Ej):
						result.append((Ei,Ej));
		return result;
		
	def computeSegmentalRectangleComponents(self):
		result = [];		
		boundaryRectangles = self.computeDegenerateRectangles();
		maxAspectRatio1 = RIF(0);
		while len(boundaryRectangles)>0:
			rect = boundaryRectangles.pop();
			component = [rect];
			print "New component starting with",rect,"==============================================================================================";
			while True:
				#print "old rectangle:"
				#print rect;
				adjacentRectangles = findRectangles(rect.E1,rect.E2,rect.E3,rect.E4,rect.cyclicRelabellings);
				if len(adjacentRectangles) not in [2,4]:
					print "#adjacentRectangles:",len(adjacentRectangles);
					raise NotImplementedError("Number of adjacent rectangles was != 2!");
				#print adjacentRectangles[0].edgeIndices();
				#print adjacentRectangles[1].edgeIndices();
				#print adjacentRectangles[0];
				#print adjacentRectangles[1];
			
				if not rect in adjacentRectangles:
					raise Exception("Original rectangle not found as inscribed rectangle!");
				if rect == adjacentRectangles[0]:
					rectNew = adjacentRectangles[1];
				elif rect == adjacentRectangles[1]:
					rectNew = adjacentRectangles[0];
				elif rect == adjacentRectangles[2]:
					rectNew = adjacentRectangles[3];
				elif rect == adjacentRectangles[3]:
					rectNew = adjacentRectangles[2];
									
				#raise Exception("Debug314");					
				
				#print rectNew;
				
				component.append(rectNew);
				#print "aspectRatio(<=1):",rectNew.aspectRatioSmaller1();
				print "firstEdge, aspectRatio:",rectNew.firstEdge(), rectNew.aspectRatio();
				maxAspectRatio1 = max(maxAspectRatio1,rectNew.aspectRatioSmaller1());
				if rectNew in boundaryRectangles:
					boundaryRectangles.remove(rectNew);
					print "Arrived at degenerate rectangle! Cyclic relabellings:",rectNew.cyclicRelabellings;
					break;
				rect = rectNew.reparametrizedRectangle();
			result.append(component);
			
		print "maxAspectRatio<=1:",maxAspectRatio1;
		return result;
		
	def followRectanglesStartingAt(self,rect):
		firstRect = rect;
		component = [rect];
		while True:
			#print "old rectangle:"
			#print rect;
			adjacentRectangles = findRectangles(rect.E1,rect.E2,rect.E3,rect.E4,rect.cyclicRelabellings);
			if len(adjacentRectangles) not in [2,4]:
				print "#adjacentRectangles:",len(adjacentRectangles);
				raise NotImplementedError("Number of adjacent rectangles was != 2!");
			#print adjacentRectangles[0].edgeIndices();
			#print adjacentRectangles[1].edgeIndices();
			#print adjacentRectangles[0];
			#print adjacentRectangles[1];
			
			if not rect in adjacentRectangles:
				raise Exception("Original rectangle not found as inscribed rectangle!");
			if rect == adjacentRectangles[0]:
				rectNew = adjacentRectangles[1];
			elif rect == adjacentRectangles[1]:
				rectNew = adjacentRectangles[0];
			elif rect == adjacentRectangles[2]:
				rectNew = adjacentRectangles[3];
			elif rect == adjacentRectangles[3]:
				rectNew = adjacentRectangles[2];

			#raise Exception("Debug314");					
			
			#print rectNew;
				
			component.append(rectNew);
			#print "aspectRatio(<=1):",rectNew.aspectRatioSmaller1();
			print "firstEdge, aspectRatio:",rectNew.firstEdge(), rectNew.aspectRatio();
			#maxAspectRatio1 = max(maxAspectRatio1,rectNew.aspectRatioSmaller1());
			if rectNew.isDegenerate():
				print "Arrived at degenerate rectangle! Cyclic relabellings:",rectNew.cyclicRelabellings;
				break;
			if rectNew == firstRect:
				print "Arrived at beginning! Cyclic relabellings",rectNew.cyclicRelabellings;
				break;			
			rect = rectNew.reparametrizedRectangle();
		return component;
		
	def computeRectangleComponentStartingAtMiddle(self):
		E1 = self.edges[floor((0*self.n)/4)];
		E2 = self.edges[floor((1*self.n)/4)];
		E3 = self.edges[floor((2*self.n)/4)];
		E4 = self.edges[floor((3*self.n)/4)];
		firstRectangles = findRectangles(E1,E2,E3,E4,0);
		component = [];
		if len(firstRectangles)==0:
			print "No rectangle found there.";
			return component;
		component = self.followRectanglesStartingAt(firstRectangles[0]);
		if component[0] == component[-1]:
			print "Circular component!";
			return component;
		else:
			component2 = self.followRectanglesStartingAt(firstRectangles[1]);
			component.reverse();
			component += component2;
			print "Segmental component!";
			return component;			
	
	def derivativeOfTestmap(self):
		t = self.t;
		t1,t2,t3,t4 = var("t1","t2","t3","t4");
		px = self.parametrizationX;
		py = self.parametrizationY;
		p1x = px(t=t1+t+0/4);
		p1y = py(t=t1+t+0/4);
		p2x = px(t=t2+t+1/4);
		p2y = py(t=t2+t+1/4);
		p3x = px(t=t3+t+2/4);
		p3y = py(t=t3+t+2/4);
		p4x = px(t=t4+t+3/4);
		p4y = py(t=t4+t+3/4);
		'''
		eq1 = p1x+p3x-p2x-p4x;
		eq2 = p1y+p3y-p2y-p4y;
		eq3 = (p1x+p2x-p3x-p4x)*(p1x-p2x-p3x+p4x) + (p1y+p2y-p3y-p4y)*(p1y-p2y-p3y+p4y);
		eq4 = t1+t2+t3+t4;
		M = matrix(SR,4,4);
		#print M;
		for i in range(4):
			ti = (t1,t2,t3,t4)[i];
			#print "ti:",ti;
			for j in range(4):
				eqj = (eq1,eq2,eq3,eq4)[j];
				#print "eqj:",eqj;
				#d = eqj.derivative(ti);
				#print "d:",d;
				#print "debug1:",d(t1=0);
				#print "debug2:",d(t2=0);
				#print "debug3:",d(t3=0);
				#print "debug4:",d(t4=0);
				M[i,j] = eqj.derivative(ti)(t1=0,t2=0,t3=0,t4=0);
				#M[i,j] = d.subs(t1=0).subs(t2=0).subs(t3=0).subs(t4=0);
				#print "Mij:",M[i,j];
		'''
		dp1x = p1x.derivative(t1).subs(t1=0);		
		dp1y = p1y.derivative(t1).subs(t1=0);		
		dp2x = p2x.derivative(t2).subs(t2=0);		
		dp2y = p2y.derivative(t2).subs(t2=0);		
		dp3x = p3x.derivative(t3).subs(t3=0);		
		dp3y = p3y.derivative(t3).subs(t3=0);		
		dp4x = p4x.derivative(t4).subs(t4=0);		
		dp4y = p4y.derivative(t4).subs(t4=0);
		M = matrix(SR,3,3);
		M[0,0] =  (p1x-p2x)*dp1x+(p1y-p2y)*dp1y;
		M[0,1] =  (p1x-p4x)*dp1x+(p1y-p4y)*dp1y;
		M[0,2] =  (p1x-p3x)*dp1x+(p1y-p3y)*dp1y;
		M[1,0] =  (p2x-p1x)*dp2x+(p2y-p1y)*dp2y;
		M[1,1] = -(p2x-p3x)*dp2x-(p2y-p3y)*dp2y;
		M[1,2] = -(p2x-p4x)*dp2x-(p2y-p4y)*dp2y;
		M[2,0] = -(p3x-p4x)*dp3x-(p3y-p4y)*dp3y;
		M[2,1] = -(p3x-p2x)*dp3x-(p3y-p2y)*dp3y;
		M[2,2] =  (p3x-p1x)*dp3x+(p3y-p1y)*dp3y;
		for i in range(3):
			for j in range(3):
				M[i,j] = M[i,j].subs(t1=0).subs(t2=0).subs(t3=0).subs(t4=0);		
		print M;
		return M;
		
	def determinantOfTestmap(self):
		return det(self.derivativeOfTestmap());
		
	def plotDeterminantOfTestmap(self):
		n = 100;
		ts = [x/n for x in range(n+1)];
		M = self.derivativeOfTestmap();
		dets = [M.substitute(t=ti).change_ring(RR).det() for ti in ts];
		list_plot(list(zip(ts,dets))).show();
		#list_plot(dets);
		return;
		
	def determinantOfTestmapAsPolynomial(self):
		R.<p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,dp1x,dp1y,dp2x,dp2y,dp3x,dp3y,dp4x,dp4y,c> = QQ[];
		M = matrix(R,3,3);
		M[0,0] =  (p1x-p2x)*dp1x+(p1y-p2y)*dp1y;
		M[0,1] =  (p1x-p4x)*dp1x+(p1y-p4y)*dp1y;
		M[0,2] =  (p1x-p3x)*dp1x+(p1y-p3y)*dp1y;
		M[1,0] =  (p2x-p1x)*dp2x+(p2y-p1y)*dp2y;
		M[1,1] = -(p2x-p3x)*dp2x-(p2y-p3y)*dp2y;
		M[1,2] = -(p2x-p4x)*dp2x-(p2y-p4y)*dp2y;
		M[2,0] = -(p3x-p4x)*dp3x-(p3y-p4y)*dp3y;
		M[2,1] = -(p3x-p2x)*dp3x-(p3y-p2y)*dp3y;
		M[2,2] =  (p3x-p1x)*dp3x+(p3y-p1y)*dp3y;
		
		'''
		eq1 = p1x-p2x+p3x-p4x;
		eq2 = p1y-p2y+p3y-p4y;
		eq3 = dp1x-dp2x+dp3x-dp4x;
		eq4 = dp1y-dp2y+dp3y-dp4y;
		
		I = Ideal([eq1,eq2,eq3,eq4]);
		S = R.quotient_ring(I);
		N = M.change_ring(S);
		print "N:",N;
		print "det(N):",det(N);
		f = factor(det(N));
		print "#factors:",len(f);
		'''
		
		subst = {};
		subst[p4x] = p1x-p2x+p3x;
		subst[p4y] = p1y-p2y+p3y;
		subst[dp4x] = dp1x-dp2x+dp3x;
		subst[dp4y] = dp1y-dp2y+dp3y;
		d = det(M)/2;
		d = d.subs(subst);
		print "d:",d;
		f = d.factor();
		print "#f:",len(f);
		print "f:",f;
		f0 = f[0][0];
		f1 = f[1][0];
		print "f0:",f0;
		print "f1:",f1;

		subst[p3x] = -p1x; #may assume center at the origin
		subst[p3y] = -p1y; #may assume center at the origin
		f0 = f0.subs(subst)/2;
		f1 = f1.subs(subst);
		print "f0:",f0; #f0=0 happens iff P1=P2 or P1=P3, can thus ignore that.
		print "f1:",f1;
		
		translation = {};
		#translation[dp1x] = dp1x+c;
		#translation[dp2x] = dp2x+c;
		#translation[dp3x] = dp3x+c;
		#translation[dp4x] = dp4x+c;
		print (f1.subs(translation)-f1).factor();
		
		
		'''
		[ 0, 1,-1] 
		[-1, 0, 1]
		[ 1,-1, 0]
		'''
		
		return det(M);

def zerosOf2x2QuadraticForm(Q):
	a = Q[0,0];
	b = Q[0,1];
	c = Q[1,1];
	if not a.contains_zero():
		mp2 = -b/a;
		q = c/a;
		D = mp2^2 - q;
		if D<0:
			return [];
		if D==0:
			return [vector((mp2,1))];
		else:
			sqrtD = sqrt(D);
			return [vector((mp2+sqrtD,1)),vector((mp2-sqrtD,1))];
	elif not c.contains_zero():
		print "swap coordinates"
		mp2 = -b/c;
		q = a/c;
		D = mp2^2 - q;
		if D<0:
			return [];
		if D==0:
			return [vector((1,mp2))];
		else:
			sqrtD = sqrt(D);
			return [vector((1,mp2+sqrtD)),vector((1,mp2-sqrtD))];
	else:
		raise Exception("Not enough precision for quadratic form...");

def argMax(L):
	#L is list
	result = 0;
	for i in range(1,len(L)):
		if L[result] < L[i]:
			result = i;
	return result;

def findRectangles(E1,E2,E3,E4,cyclicRelabelling=0):
	#Construct a quadratic equation sytsem with variables t1,t2,t3,t4, which parametrize
	#4 points, one on each edge, t_i=0 corresponding to Ei.P1 and t_i=1 to Ei.P2.
	#There are two linear equations saying making P1P2P3P4 a parallelogram.
	#One further quadratic equation makes the diagonals equally long.

	if E1==E2:
		needQuadraticEquation = False;
	elif E2==E3:
		return findRectangles(E2,E3,E4,E1,cyclicRelabelling+1);
	elif E3==E4:
		return findRectangles(E3,E4,E1,E2,cyclicRelabelling+2);
	elif E4==E1:
		return findRectangles(E4,E1,E2,E3,cyclicRelabelling+3);
	else:
		needQuadraticEquation = True;
	
	#print E1.index(),E2.index(),E3.index(),E4.index();
	
	solutions = [];
	solutionsS = [];

	if needQuadraticEquation:
		#We use coordinates of Point P1..P4 wrt. "basis" (t1,t2,t3,t4,1):
		P1x = vector((E1.direction[0],0,0,0,E1.P1.xy[0]));
		P1y = vector((E1.direction[1],0,0,0,E1.P1.xy[1]));
		P2x = vector((0,E2.direction[0],0,0,E2.P1.xy[0]));
		P2y = vector((0,E2.direction[1],0,0,E2.P1.xy[1]));
		P3x = vector((0,0,E3.direction[0],0,E3.P1.xy[0]));
		P3y = vector((0,0,E3.direction[1],0,E3.P1.xy[1]));
		P4x = vector((0,0,0,E4.direction[0],E4.P1.xy[0]));
		P4y = vector((0,0,0,E4.direction[1],E4.P1.xy[1]));
		M13x = 1/2*(P1x+P3x);
		M13y = 1/2*(P1y+P3y);
		M24x = 1/2*(P2x+P4x);
		M24y = 1/2*(P2y+P4y);

		linearEquations = [];
		#linearEquations.append(vector((0,0,0,0,1))); #Makes last coordinate equal to one.
		linearEquations.append(M13x-M24x);
		linearEquations.append(M13y-M24y);

		boundaryEquations = [];
		boundaryEquations.append(vector(RIF,(1,0,0,0, 0)));
		boundaryEquations.append(vector(RIF,(1,0,0,0,-1)));
		boundaryEquations.append(vector(RIF,(0,1,0,0, 0)));
		boundaryEquations.append(vector(RIF,(0,1,0,0,-1)));
		boundaryEquations.append(vector(RIF,(0,0,1,0, 0)));
		boundaryEquations.append(vector(RIF,(0,0,1,0,-1)));
		boundaryEquations.append(vector(RIF,(0,0,0,1, 0)));
		boundaryEquations.append(vector(RIF,(0,0,0,1,-1)));

		#We have only 3 linear equations.
		#Need to include a quadratic one:
		Q  = column_matrix(P1x-P3x) * matrix(P1x-P3x);
		Q += column_matrix(P1y-P3y) * matrix(P1y-P3y);
		Q -= column_matrix(P2x-P4x) * matrix(P2x-P4x);
		Q -= column_matrix(P2y-P4y) * matrix(P2y-P4y);
		#print "dimensions(Q):",Q.dimensions();
		#print "rank(Q):",Q.rank();

				
		M0 = matrix(linearEquations);
		K0 = M0.right_kernel();
		if K0.dimension() != 3:
			raise Exception("LES has too many solutions.");
		KM0 = K0.matrix().transpose();
		Q0 = KM0.transpose() * Q * KM0;
		
		if det(Q0)<0:
			Q0 = -Q0;
		#Now Q0 has one positive and two negative eigenvalues.
		t = max(0,-Q0.trace());
		Q0t = Q0 + t;
		#Now Q0t has only positive eigenvalues, the biggest one being
		#the positive one of Q0 plus t.
		w0 = vector((Q0t^11117).column(0));
		#w0 is roughly an eigenvector for Q0 corresponding to
		#the positive eigenvalue.
		wQ = Q * KM0 * w0;
		#print "wQ:",wQ;
		
		w0Q0 = Q0 * w0;
		
		#Construct a vector w0comp that satisfies w0comp * Q0 * w0 = 0:
		if w0Q0[0].contains_zero():
			w0comp = vector((RIF(0),w0Q0[2],-w0Q0[1]));
		else:
			w0comp = vector((w0Q0[1],-w0Q0[0],RIF(0)));
		w0compQ = Q * KM0 * w0comp;
		
		
		#print Q0;
		#Q0 is quadratic form on the 3-dimensional VS of inscribed paralellograms.
		#print "Q0's signature:",QuadraticForm(Q0).signature();
		
		for bEq in boundaryEquations:
			Mb = matrix(linearEquations+[bEq]);
			#print "Mb:",Mb;
			Kb = Mb.right_kernel(algorithm="generic",basis="pivot");
			if Kb.dimension() != 2:
				raise Exception("LES has too many solutions.");
			KbM = Kb.matrix().transpose();
			#print KbM;
			
			#Mb.echelonize(algorithm="classical");
			#print "Mb:",Mb;
			#k1 = Mb.column(3).list()+[-1,0];
			#k2 = Mb.column(4).list()+[0,-1];
			#KbM = column_matrix([k1,k2]);
			#print "KbM:",KbM;

			Qb = KbM.transpose() * Q * KbM;
			#print "Qb:",Qb;
			
			#qb = QuadraticForm(Qb);
			#print "rank of restricted quadratic form:",Qb.rank();
			#print "signature of restricted quadratic form",qb.signature();
			zeros = zerosOf2x2QuadraticForm(Qb);
			#print "zeros of Qb:",zeros;
			#print "#zeros of Qb:",len(zeros);
			for zero in zeros:
				s = KbM * zero;
				if not s[4].contains_zero():
					s = (1/s[4])*s;
					#print "s:",s;
					if s[0].overlaps(RIF(0,1)):
						if s[1].overlaps(RIF(0,1)):
							if s[2].overlaps(RIF(0,1)):
								if s[3].overlaps(RIF(0,1)):
									R = Rectangle(E1,E2,E3,E4,s[0],s[1],s[2],s[3],cyclicRelabelling);
									if R not in solutions:
										if E1.nextEdge() == E2 and E3.nextEdge() == E4 and (s[0]-1).contains_zero() and s[1].contains_zero() and (s[2]-1).contains_zero() and s[3].contains_zero():
											s = E1.P2.xy - E3.P2.xy;
											if not (E1.direction*s) * (E2.direction*s) >= 0:
												if not (E3.direction*s) * (E4.direction*s) >= 0:
													solutions.append(R);
													solutionsS.append(s);
										elif E2.nextEdge() == E3 and E4.nextEdge() == E1 and (s[1]-1).contains_zero() and s[2].contains_zero() and (s[3]-1).contains_zero() and s[0].contains_zero():
											s = E2.P2.xy - E4.P2.xy;
											if not (E2.direction*s) * (E3.direction*s) >= 0:
												if not (E4.direction*s) * (E1.direction*s) >= 0:
													solutions.append(R);
													solutionsS.append(s);
										else:
											#print str(R);
											solutions.append(R);
											solutionsS.append(s);
		
		if len(solutions)>2:
			if len(solutions)!=4:
				print "#solutions:",len(solutions);
				for R in solutions:
					print R;
				raise Exception("Strange number of solutions.");
			for s in solutionsS:
				if (wQ*s).contains_zero():
					raise Exception("Not enough precision");
			signs = [(wQ*s)>0 for s in solutionsS];
			#print "signs",signs;
			if all(signs) or all(not x for x in signs):
				#All four solutions lie on the same branch of the hyperbola.
				#Need to order them:
				indices = range(len(solutions));
				keys = [w0compQ * solutionsS[i] for i in indices];
				#for R in solutions:
				#	print R;
				#print "keys:",keys;
				for i in range(len(keys)):
					for j in range(i+1,len(keys)):
						if keys[i].overlaps(keys[j]):
							raise Exception("keys overlap, need higher precision!");
				indices.sort(key = lambda i : keys[i]);
				solutions = [solutions[i] for i in indices];			
			else:
				solutionsPos = [solutions[i] for i in range(len(solutions)) if signs[i]];
				solutionsNeg = [solutions[i] for i in range(len(solutions)) if not signs[i]];
				#print "#solutions:",len(solutionsPos),"+",len(solutionsNeg);
				solutions = solutionsPos + solutionsNeg;
		
	else:
		#We can use E1=E2.
		#This makes it into a linear equation system!

		#We use coordinates of Point P3,P4 wrt. "basis" (t3,t4,1):
	
		P3x = vector(RIF,(E3.direction[0],0,E3.P1.xy[0]));
		P3y = vector(RIF,(E3.direction[1],0,E3.P1.xy[1]));
		P4x = vector(RIF,(0,E4.direction[0],E4.P1.xy[0]));
		P4y = vector(RIF,(0,E4.direction[1],E4.P1.xy[1]));

		dist3 = E1.normal[0]*P3x + E1.normal[1]*P3y;
		dist4 = E1.normal[0]*P4x + E1.normal[1]*P4y;
		
		T1 = (1/E1.normSq) * (E1.direction[0]*P4x + E1.direction[1]*P4y + vector(RIF,(0,0,E1.direction*(-E1.P1.xy))));
		T2 = (1/E2.normSq) * (E2.direction[0]*P3x + E2.direction[1]*P3y + vector(RIF,(0,0,E2.direction*(-E2.P1.xy))));
		
		#print "T1:",T1;
		#print "T2:",T2;
		
		linearEquations = [dist3-dist4];
		
		boundaryEquations = [];
		boundaryEquations.append(vector(RIF,(1,0, 0))); #t3=0
		boundaryEquations.append(vector(RIF,(1,0,-1))); #t3=1
		boundaryEquations.append(vector(RIF,(0,1, 0))); #t4=0
		boundaryEquations.append(vector(RIF,(0,1,-1))); #t4=1
		boundaryEquations.append(T1+vector(RIF,(0,0, 0))); #t1=0
		boundaryEquations.append(T1+vector(RIF,(0,0,-1))); #t1=1
		boundaryEquations.append(T2+vector(RIF,(0,0, 0))); #t2=0
		boundaryEquations.append(T2+vector(RIF,(0,0,-1))); #t2=1

		for bEq in boundaryEquations:
			Mb = matrix(linearEquations+[bEq]);
			#print "Mb:",Mb;
			Kb = Mb.right_kernel(algorithm="generic",basis="pivot");
			if Kb.dimension() != 1:
				raise Exception("LES has too many solutions.");
			KbM = Kb.matrix().transpose();
			s = Kb.basis()[0];
			if not s[2].contains_zero():
				s = (1/s[2]) * s;
				#print "s:",s;
				#print "debug:", (s[0]*T1[0]).lower(), (s[0]*T1[0]).upper(), s[1]*T1[1], s[2]*T1[2],s*T1
				#print "debug:", s[0]*T1[0] + s[1]*T1[1] + s[2]*t1[2],s*T1
				#print "debug:", s[2]*T1[2] + s[1]*T1[1] + s[0]*t1[0],s*T1
				t3 = s[0];
				t4 = s[1];
				#t1 = T1 * s;
				#t2 = T2 * s;
				t1 = sum([T1[i] * s[i] for i in range(3)]);
				t2 = sum([T2[i] * s[i] for i in range(3)]);
				#print "t1,t2,t3,t4:",t1,t2,t3,t3;
				if t3.overlaps(RIF(0,1)):
					if t4.overlaps(RIF(0,1)):
						if t1.overlaps(RIF(0,1)):
							if t2.overlaps(RIF(0,1)):
								R = Rectangle(E1,E2,E3,E4,t1,t2,t3,t4,cyclicRelabelling);
								if R not in solutions:
									#print str(R);
									solutions.append(R);

	#print "#solutions:",len(solutions);
	#for solution in solutions:
	#	print solution;
	
		
	return solutions;
	
C = Curve(P=P1,t=t,n=101)
#print "Number of degenerate rectangles:", len([str(R) for R in C.computeDegenerateRectangles()])
#R = C.computeDegenerateRectangles()[0]; #0,4,4,9
#R = C.computeDegenerateRectangles()[3]; #3,3,7,8
#R = C.computeDegenerateRectangles()[-1];
#print str(R);
#findRectangles(R.E1,R.E2,R.E3,R.E4);
#C.show();
#C.computeSegmentalRectangleComponents();
#C.computeRectangleComponentStartingAtMiddle();
#detTest = C.determinantOfTestmap();
#M = C.derivativeOfTestmap();
#C.plotDeterminantOfTestmap();
C.determinantOfTestmapAsPolynomial();
