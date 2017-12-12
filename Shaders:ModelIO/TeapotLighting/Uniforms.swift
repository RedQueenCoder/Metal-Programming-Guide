//
//  Uniforms.swift
//  TeapotLighting
//
//  Created by Janie Clayton on 1/26/17.
//  Copyright © 2017 RedQueenCoder. All rights reserved.
//

import Foundation
import simd

struct Uniforms {
    let lightPosition:float4
    let color:float4
    let reflectivity:float3
    let lightIntensity:float3
    let projectionMatrix:Matrix4x4
    let modelViewMatrix:Matrix4x4
}
