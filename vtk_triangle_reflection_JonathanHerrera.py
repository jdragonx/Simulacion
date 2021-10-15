#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Escuela Politécnica Nacional
#Facultad de Ingeniería en Sistemas
#Modelos y Simulación
#Jonathan Herrera

import vtk
import pandas as pd
import numpy as np

def triangle(p0,p1,p2,O,Pi,Pr):
    
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
    renderWindowInteractor = vtk.vtkRenderWindowInteractor()
    renderWindowInteractor.SetRenderWindow(renderWindow)

    renderer.AddActor(actor)

    points = vtk.vtkPoints()
    points.InsertNextPoint(O)
    points.InsertNextPoint(Pi)
    points.InsertNextPoint(Pr)

    lines = vtk.vtkCellArray()

    for i in range(0, 2):
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
    actor.GetProperty().SetColor(colors.GetColor3d('Red'))

    renderer.AddActor(actor)
    renderer.SetBackground(colors.GetColor3d("Silver"))

    renderWindow.Render()
    renderWindowInteractor.Start()

if __name__=='__main__':
    points = pd.read_csv('triangle_points.csv',header=None).values
    a = points[2] - points[1]
    b = points[0] - points[1]
    Vn = np.cross(a,b)
    Vn = Vn/np.linalg.norm(Vn)
    O = points[3]
    Vi = points[4]
    Vi = Vi/np.linalg.norm(Vi)
    Vr = Vi - np.matmul(Vi,Vn)*2*Vn
    Vb = points[0] - O
    d = np.matmul(Vn,Vb)/np.matmul(Vn,Vi)
    Pi = O + d*Vi
    Pr = Vr+Pi
    triangle(points[0],points[1],points[2],O,Pi,Pr)