#Escuela Politécnica Nacional
#Facultad de Ingeniería en Sistemas
#Modelos y Simulación
#Jonathan Herrera

import vtk
import pandas as pd
import figures
import numpy as np
time = 0.
speed = 10
rate = 200
permanent_actors = []
temporal_actors = []
showLines = False
max_bounce = 50
nrays = 12
sources = []
n_sources= 1
energy = np.array([100])
colors_list = pd.read_csv('colors.csv',header=None).values
scale = 0.1
radius = (energy/nrays)*scale
alfa = 0.2
delta = 0.15
divisions = 2

def callback_func(caller, timer_event):
    global time
    time+=rate/1000
    for actor in temporal_actors:
        renderer.RemoveActor(actor)

    temporal_actors.clear()
    for i,source in enumerate(sources):
        ray_actors(speed*time,source,i)
    for actor in temporal_actors:
        renderer.AddActor(actor)
    renWin.Render()

def ray_actors(distance,source,id_source):
    np.random.seed(id_source*2)
    color_end = colors_list[np.random.randint(0,len(colors_list))][0]
    color_line = colors_list[np.random.randint(0,len(colors_list))][0]
    rad = radius[id_source]
    for ray in source:
        temporal_actors.extend(ray.to_actor(showLines,distance,color_end,color_line,rad))


colors = vtk.vtkNamedColors()

cube_points = pd.read_csv('cube_points.csv',header=None).values

camera = vtk.vtkCamera()
camera.SetPosition(1, 1, 1)
camera.SetFocalPoint(0, 0, 0)

renderer = vtk.vtkRenderer()
renWin = vtk.vtkRenderWindow()
renWin.AddRenderer(renderer)

iren = vtk.vtkRenderWindowInteractor()
iren.SetRenderWindow(renWin)

room = figures.room(cube_points,n_sources,nrays,max_bounce,divisions)
roomActor = room.to_actor()
permanent_actors.append(roomActor)

sources = room.sources
for i,source in enumerate(sources):
    ray_actors(0,source,i)

for actor in temporal_actors:
    renderer.AddActor(actor)

for gr in room.sources_gr:
    permanent_actors.append(gr)

for actor in permanent_actors:
    renderer.AddActor(actor)
renderer.SetActiveCamera(camera)
renderer.ResetCamera()
renderer.SetBackground(colors.GetColor3d(colors_list[15][0]))

renWin.SetSize(600, 600)
renWin.SetWindowName("Cube")

iren.Initialize()
iren.CreateRepeatingTimer(rate)
iren.AddObserver("TimerEvent", callback_func)

renWin.Render()
iren.Start()