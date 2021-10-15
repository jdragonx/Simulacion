#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Escuela Politécnica Nacional
#Facultad de Ingeniería en Sistemas
#Modelos y Simulación

import vtk
import pandas as pd

def mkVtkIdList(it):
    vil = vtk.vtkIdList()
    for i in it:
        vil.InsertNextId(int(i))
    return vil


def main():
    colors = vtk.vtkNamedColors()

    x = pd.read_csv('points.csv',header=None).values
    
    pts = [(0, 1, 2, 3), (4, 5, 6, 7), (0, 1, 5, 4),
           (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]

    cube = vtk.vtkPolyData()
    points = vtk.vtkPoints()
    polys = vtk.vtkCellArray()
    scalars = vtk.vtkFloatArray()

    for i, xi in enumerate(x):
        points.InsertPoint(i, xi)
    for pt in pts:
        polys.InsertNextCell(mkVtkIdList(pt))
    for i, _ in enumerate(x):
        scalars.InsertTuple1(i, i)

    cube.SetPoints(points)
    cube.SetPolys(polys)
    cube.GetPointData().SetScalars(scalars)

    cubeMapper = vtk.vtkPolyDataMapper()
    cubeMapper.SetInputData(cube)
    cubeMapper.SetScalarRange(cube.GetScalarRange())
    cubeActor = vtk.vtkActor()
    cubeActor.SetMapper(cubeMapper)

    camera = vtk.vtkCamera()
    camera.SetPosition(1, 1, 1)
    camera.SetFocalPoint(0, 0, 0)

    renderer = vtk.vtkRenderer()
    renWin = vtk.vtkRenderWindow()
    renWin.AddRenderer(renderer)

    iren = vtk.vtkRenderWindowInteractor()
    iren.SetRenderWindow(renWin)

    renderer.AddActor(cubeActor)
    renderer.SetActiveCamera(camera)
    renderer.ResetCamera()
    renderer.SetBackground(colors.GetColor3d("Cornsilk"))

    renWin.SetSize(600, 600)
    renWin.SetWindowName("Cube")

    renWin.Render()
    iren.Start()


if __name__ == "__main__":
    main()