#Escuela Politécnica Nacional
#Facultad de Ingeniería en Sistemas
#Modelos y Simulación
#Jonathan Herrera

import vtk 
import numpy as np
import pandas as pd
from functools import lru_cache
np.random.seed(5)

class source:
    def __init__(self,nrays,center,max_bounce,planes):
        self.nrays = nrays
        self.rays = []
        self.center = center
        for vector in fibonacci_sphere(self.nrays):
            self.rays.append(ray_actor(self.center,vector,max_bounce,planes))
        self.graph = icosahedron(center)

def icosahedron(center,size=0.5):
    lut = vtk.vtkLookupTable()
    lut.SetNumberOfTableValues(1)
    lut.SetTableRange(0.0, 1.0)
    lut.Build()
    for i in range(1):
        lut.SetTableValue(i, np.random.random(), np.random.random(), np.random.random())

    ico = vtk.vtkPlatonicSolidSource()
    ico.SetSolidTypeToIcosahedron()

    color = vtk.vtkApplyColors()
    color.SetInputConnection(ico.GetOutputPort())

    # Visualize
    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputConnection(color.GetOutputPort())
    mapper.SetLookupTable(lut)

    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    actor.SetPosition(center)
    actor.SetScale(size)

    return actor

@lru_cache(maxsize=None)
def fibonacci_sphere(samples=1):

    points = []
    phi = np.pi * (3. - np.sqrt(5.))

    for i in range(samples):
        y = 1 - (i / float(samples - 1)) * 2
        radius = np.sqrt(1 - y * y)

        theta = phi * i

        x = np.cos(theta) * radius
        z = np.sin(theta) * radius

        points.append([x, y, z])

    return points

@lru_cache(maxsize=None)
def mkVtkIdList(it):
    vil = vtk.vtkIdList()
    for i in it:
        vil.InsertNextId(int(i))
    return vil

class room:
    def __init__(self,x,n_sources,nrays,max_bounce,divisions):
        er = pd.read_csv('emisor_receptor.csv',header=None).values
        self.div = divisions
        order = [((0, 1, 2), (0, 2, 3)), ((5, 4, 7), (5, 7, 6)), ((4, 5, 1), (4, 1, 0)),
                 ((5, 6, 2), (5, 2, 1)), ((6, 7, 3), (6, 3, 2)), ((7, 4, 0), (7, 0, 3))]
        self.x = x
        self.order = order
        self.planes = list()
        for plane in order:
            Vn = np.cross(x[plane[0][1]]-x[plane[0][0]],x[plane[0][-1]]-x[plane[0][0]])
            Vn = Vn/np.linalg.norm(Vn)
            self.planes.append((Vn,x[plane[0][0]]))

        for _ in range(divisions):
            new_x = list()
            new_order = list()
            for i, plane in enumerate(order):
                new_x.append(x[plane[0][0]])
                new_x.append(x[plane[0][1]])
                new_x.append(x[plane[0][2]])
                new_x.append(x[plane[1][2]])
                new_x.append((x[plane[0][0]] + x[plane[0][1]])/2)
                new_x.append((x[plane[0][0]] + x[plane[0][2]])/2)
                new_x.append((x[plane[0][1]] + x[plane[0][2]])/2)
                new_x.append((x[plane[0][0]] + x[plane[1][2]])/2)
                new_x.append((x[plane[0][2]] + x[plane[1][2]])/2)
                new_order.append(((0+(i*9), 4+(i*9), 5+(i*9)), (0+(i*9), 5+(i*9), 7+(i*9))))
                new_order.append(((4+(i*9), 1+(i*9), 6+(i*9)), (4+(i*9), 6+(i*9), 5+(i*9))))
                new_order.append(((7+(i*9), 5+(i*9), 8+(i*9)), (7+(i*9), 8+(i*9), 3+(i*9))))
                new_order.append(((5+(i*9), 6+(i*9), 2+(i*9)), (5+(i*9), 2+(i*9), 8+(i*9))))
            x = np.array(new_x)
            order = new_order
        self.x = x
        self.order = order
        self.triangles = list()
        for plane in self.order:
            for triangle in plane:
                self.triangles.append((self.x[triangle[0]], self.x[triangle[1]], self.x[triangle[2]]))        
        
        self.energy = list()

        for triangle in self.triangles:
            point = 
            p_energy = list()
            for tr in self.triangles:
                if not inner(point ,tr[0], tr[1], tr[2]):
                    v1 = tr[0] - point
                    v2 = tr[1] - point
                    v3 = tr[2] - point

                    v1 = v1/np.linalg.norm(v1)
                    v2 = v2/np.linalg.norm(v2)
                    v3 = v3/np.linalg.norm(v3)

                    p1 = point + v1
                    p2 = point + v2
                    p3 = point + v3

                    av1 = p1-p2
                    av2 = p1-p3

                    area = np.linalg.norm(np.cross(av1,av2))/2
                    p_energy.append(area)
                else:
                    p_energy.append(0)
            p_energy = np.array(p_energy)
            p_energy = p_energy/np.sum(p_energy)
            self.energy.append(p_energy) 

        self.sources = []
        self.sources_gr = []
        for i in range(n_sources):
            sour = source(nrays,er[i],max_bounce,self.planes)
            self.sources.append(sour.rays)
            self.sources_gr.append(sour.graph)

    @lru_cache(maxsize=None)
    def to_actor(self):

        room = vtk.vtkPolyData()
        points = vtk.vtkPoints()
        polys = vtk.vtkCellArray()
        scalars = vtk.vtkFloatArray()

        for i, xi in enumerate(self.x):
            points.InsertPoint(i, xi)
            scalars.InsertTuple1(i, i)
        for plane in self.order:
            for pt in plane:
                polys.InsertNextCell(mkVtkIdList(pt))            

        room.SetPoints(points)
        room.SetPolys(polys)
        room.GetPointData().SetScalars(scalars)

        roomMapper = vtk.vtkPolyDataMapper()
        roomMapper.SetInputData(room)
        roomMapper.SetScalarRange(room.GetScalarRange())
        roomActor = vtk.vtkActor()
        roomActor.SetMapper(roomMapper)
        roomActor.GetProperty().SetRepresentationToWireframe()

        return roomActor

@lru_cache(maxsize=None)
def sphere_actor(end_color,center,radius):
    
    colors = vtk.vtkNamedColors()

    sphereSource = vtk.vtkSphereSource()
    sphereSource.SetCenter(center)
    sphereSource.SetRadius(radius)
    
    sphereSource.SetPhiResolution(100)
    sphereSource.SetThetaResolution(100)

    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputConnection(sphereSource.GetOutputPort())

    sphere = vtk.vtkActor()
    sphere.SetMapper(mapper)
    sphere.GetProperty().SetColor(colors.GetColor3d(end_color))

    return sphere

def inner(p,p0,p1,p2):
    v1 = p0-p
    v2 = p1-p
    v3 = p2-p
    v1 = v1/np.linalg.norm(v1)
    v2 = v2/np.linalg.norm(v2)
    v3 = v3/np.linalg.norm(v3)
    a1 = np.arccos(np.matmul(v1, v2))
    a2 = np.arccos(np.matmul(v1, v3))
    a3 = np.arccos(np.matmul(v2, v3))
    if a1+a2+a3 == 2*np.pi:
        return True
    return False
    

class ray_actor:
    def __init__(self,start,Vi,bounces,planes):
        self.start = start
        self.cum_distances = [0]
        self.distance = 0
        distances = [0]
        self.energy = list()
        Vi = Vi/np.linalg.norm(Vi)
        self.points = [start]
        for _ in range(bounces+1):
            d1 = float('inf')
            Vr1 = 0
            Vi1 = 0
            for plane in planes:
                Vn = plane[0]
                if(np.matmul(Vn, Vi)<0):
                    Vr = Vi - np.matmul(Vi,Vn)*2*Vn
                    Vb = plane[1] - start
                    d = np.matmul(Vn,Vb)/np.matmul(Vn,Vi)
                    if d < d1:
                        d1 = d
                        Vr1 = Vr
                        Vi1 = Vi
                        
            Pi = start + d1*Vi1
            start = Pi
            Vi = Vr1
            
            
            distances.append(np.linalg.norm(Pi-self.points[-1]))
            self.cum_distances.append(self.cum_distances[-1]+distances[-1])
            self.points.append(Pi)

    @lru_cache(maxsize=None)
    def to_actor(self,showLines=True,distance=0,end_color='yellow',line_color='blue',radius=0.1,alfa=0.2,delta=0.15):
        self.distance = distance
        points = vtk.vtkPoints()
        points.InsertNextPoint(self.start)
        sp = 0
        n_lines = 0
        
        for point,i,cum_distance in zip(self.points,range(len(self.points)),self.cum_distances):
            if(cum_distance<=self.distance):
                points.InsertNextPoint(point)
                n_lines +=1
            elif(cum_distance>self.distance):
                vect = point-self.points[i-1]
                vect = vect/np.linalg.norm(vect)
                vect = vect*(self.distance-self.cum_distances[i-1])
                p = self.points[i-1] + vect
                points.InsertNextPoint(p)
                n_lines+=1
                rd = radius*((1-alfa)*(1-delta))**i
                sp = sphere_actor(end_color,tuple(p),rd)
                break

        lines = vtk.vtkCellArray()
        for i in range(n_lines):
            line = vtk.vtkLine()
            line.GetPointIds().SetId(0, i)
            line.GetPointIds().SetId(1, i + 1)
            lines.InsertNextCell(line)

        linesPolyData = vtk.vtkPolyData()
        linesPolyData.SetPoints(points)
        linesPolyData.SetLines(lines)
        colors = vtk.vtkNamedColors()

        mapper = vtk.vtkPolyDataMapper()
        mapper.SetInputData(linesPolyData)

        actor = vtk.vtkActor()
        actor.SetMapper(mapper)
        actor.GetProperty().SetLineWidth(4)
        actor.GetProperty().SetColor(colors.GetColor3d(line_color))

        if (showLines):
            return [actor, sp]
        return [sp]