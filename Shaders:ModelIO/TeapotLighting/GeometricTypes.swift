//
//  GeometricTypes.swift
//  SwiftMetalDemo
//
//  Created by Warren Moore on 11/4/14.
//  Copyright (c) 2014 Warren Moore. All rights reserved.
//

import Foundation

struct Vector4
{
    var x: Float32
    var y: Float32
    var z: Float32
    var w: Float32
}

struct Vector3
{
    var r: Float32
    var g: Float32
    var b: Float32
}

struct ColorRGBA
{
    var r: Float32
    var g: Float32
    var b: Float32
    var a: Float32
}

struct TexCoords
{
    var u: Float32
    var v: Float32
}

struct ColoredVertex
{
    var position: Vector4
    var color: ColorRGBA
}

struct Vertex
{
    var position: Vector4
    var normal: Vector4
    var texCoords: TexCoords
}

struct Matrix4x4
{
    var X: Vector4
    var Y: Vector4
    var Z: Vector4
    var W: Vector4

    init()
    {
        X = Vector4(x: 1, y: 0, z: 0, w: 0)
        Y = Vector4(x: 0, y: 1, z: 0, w: 0)
        Z = Vector4(x: 0, y: 0, z: 1, w: 0)
        W = Vector4(x: 0, y: 0, z: 0, w: 1)
    }
    
    static func rotationAboutAxis(_ axis: Vector4, byAngle angle: Float32) -> Matrix4x4
    {
        var mat = Matrix4x4()
        
        let c = cos(angle)
        let s = sin(angle)

        mat.X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c
        mat.X.y = axis.x * axis.y * (1 - c) - axis.z * s
        mat.X.z = axis.x * axis.z * (1 - c) + axis.y * s

        mat.Y.x = axis.x * axis.y * (1 - c) + axis.z * s
        mat.Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c
        mat.Y.z = axis.y * axis.z * (1 - c) - axis.x * s

        mat.Z.x = axis.x * axis.z * (1 - c) - axis.y * s
        mat.Z.y = axis.y * axis.z * (1 - c) + axis.x * s
        mat.Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c

        return mat
    }
    
    static func perspectiveProjection(_ aspect: Float32, fieldOfViewY: Float32, near: Float32, far: Float32) -> Matrix4x4
    {
        var mat = Matrix4x4()
        
        let fovRadians = fieldOfViewY * Float32(M_PI / 180.0)

        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        
        mat.X.x = xScale
        mat.Y.y = yScale
        mat.Z.z = zScale
        mat.Z.w = -1
        mat.W.z = wzScale

        return mat;
    }
}
