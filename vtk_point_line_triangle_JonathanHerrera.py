#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Escuela Politécnica Nacional
#Facultad de Ingeniería en Sistemas
#Modelos y Simulación

import vtk
import tkinter
from tkinter import messagebox
from tkinter import ttk

def line(p0,p1):
    
    lineSource = vtk.vtkLineSource()
    lineSource.SetPoint1(p0)
    lineSource.SetPoint2(p1)

    colors = vtk.vtkNamedColors()

    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputConnection(lineSource.GetOutputPort())
    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    actor.GetProperty().SetLineWidth(5)
    actor.GetProperty().SetColor(colors.GetColor3d("Peacock"))

    renderer = vtk.vtkRenderer()
    renderWindow = vtk.vtkRenderWindow()
    renderWindow.SetWindowName("Line")
    renderWindow.AddRenderer(renderer)
    #renderWindow.FullScreenOn()
    renderWindowInteractor = vtk.vtkRenderWindowInteractor()
    renderWindowInteractor.SetRenderWindow(renderWindow)

    renderer.SetBackground(colors.GetColor3d("Silver"))
    renderer.AddActor(actor)

    renderWindow.Render()
    renderWindowInteractor.Start()

def point(p0):
    
    colors = vtk.vtkNamedColors()
    points = vtk.vtkPoints()
    
    vertices = vtk.vtkCellArray()
    pid = [0]
    pid[0] = points.InsertNextPoint(p0)
    vertices.InsertNextCell(1, pid)

    point = vtk.vtkPolyData()

    point.SetPoints(points)
    point.SetVerts(vertices)

    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputData(point)

    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    actor.GetProperty().SetColor(colors.GetColor3d('Peacock'))
    actor.GetProperty().SetPointSize(20)

    renderer = vtk.vtkRenderer()
    renderWindow = vtk.vtkRenderWindow()
    renderWindow.SetWindowName('Point')
    renderWindow.AddRenderer(renderer)
    #renderWindow.FullScreenOn()
    renderWindowInteractor = vtk.vtkRenderWindowInteractor()
    renderWindowInteractor.SetRenderWindow(renderWindow)

    renderer.AddActor(actor)
    renderer.SetBackground(colors.GetColor3d("Silver"))

    renderWindow.Render()
    renderWindowInteractor.Start()

def triangle(p0,p1,p2):
    
    colors = vtk.vtkNamedColors()

    points = vtk.vtkPoints()
    points.InsertNextPoint(p0)
    points.InsertNextPoint(p1)
    points.InsertNextPoint(p2)

    triangle = vtk.vtkTriangle()
    triangle.GetPointIds().SetId(0, 0)
    triangle.GetPointIds().SetId(1, 1)
    triangle.GetPointIds().SetId(2, 2)

    triangles = vtk.vtkCellArray()
    triangles.InsertNextCell(triangle)

    trianglePolyData = vtk.vtkPolyData()

    trianglePolyData.SetPoints(points)
    trianglePolyData.SetPolys(triangles)

    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputData(trianglePolyData)
    actor = vtk.vtkActor()
    actor.GetProperty().SetColor(colors.GetColor3d('Peacock'))
    actor.SetMapper(mapper)

    renderer = vtk.vtkRenderer()
    renderWindow = vtk.vtkRenderWindow()
    renderWindow.SetWindowName('Triangle')
    renderWindow.AddRenderer(renderer)
    #renderWindow.FullScreenOn()
    renderWindowInteractor = vtk.vtkRenderWindowInteractor()
    renderWindowInteractor.SetRenderWindow(renderWindow)

    renderer.AddActor(actor)
    renderer.SetBackground(colors.GetColor3d("Silver"))

    renderWindow.Render()
    renderWindowInteractor.Start()

def get_points(n):
    if n == 1:
        p0 = [float(i) for i in list(p0e.get().split(','))]
        point(p0)

    elif n==2:
        p0 = [float(i) for i in list(p0e.get().split(','))]
        p1 = [float(i) for i in list(p1e.get().split(','))]
        line(p0,p1)
        
    elif n==3:
        p0 = [float(i) for i in list(p0e.get().split(','))]
        p1 = [float(i) for i in list(p1e.get().split(','))]
        p2 = [float(i) for i in list(p2e.get().split(','))]
        triangle(p0,p1,p2)

    l0.pack_forget()
    p0e.pack_forget()
    l1.pack_forget()
    p1e.pack_forget()
    l2.pack_forget()
    p2e.pack_forget()
    Go.pack_forget()

def point_points():
    l0.pack()
    p0e.pack()
    p0e.focus()
    Go.configure(text ="Ok", command = lambda: get_points(1))
    Go.pack()

def line_points():
    l0.pack()
    p0e.pack()
    p0e.focus()
    l1.pack()
    p1e.pack()
    Go.configure(text ="Ok", command = lambda: get_points(2))
    Go.pack()

def triangle_points():
    l0.pack()
    p0e.pack()
    p0e.focus()
    l1.pack()
    p1e.pack()
    l2.pack()
    p2e.pack()
    Go.configure(text ="Ok", command = lambda: get_points(3))
    Go.pack()

if __name__ == '__main__':

    top = tkinter.Tk()
    top.geometry("500x500")
    top.title('VTK selección de visualización')
    P = tkinter.Button(top, text ="Punto", command = lambda: point_points())
    P.pack()
    B = tkinter.Button(top, text ="Línea", command = lambda: line_points())
    B.pack()
    C = tkinter.Button(top, text ="Triángulo", command = lambda: triangle_points())
    C.pack()
    p0e = tkinter.Entry(top)
    p1e = tkinter.Entry(top)
    p2e = tkinter.Entry(top)
    Go = tkinter.Button(top, text ="Ok", command = lambda: get_points(1))
    l0 = tkinter.Label(top,text='Punto 1')
    l1 = tkinter.Label(top,text='Punto 2')
    l2 = tkinter.Label(top,text='Punto 3')
    top.mainloop()
    