//
//  Lighting.metal
//  TeapotLighting
//
//  Created by Janie Clayton on 1/21/17.
//  Copyright © 2017 RedQueenCoder. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    float3  position [[attribute(0)]];
    float3  normal [[attribute(1)]];
};

struct Uniforms
{
    float4 lightPosition;
    float4 color;
    packed_float3 reflectivity;
    packed_float3 intensity;
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
};

struct VertexOut
{
    float4  position [[position]];
    float4  lightIntensity;
};

vertex VertexOut lightingVertex(VertexIn vertexIn [[stage_in]],
                                constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut outVertex;
    
    float4 position = float4(vertexIn.position, 1) + float4(0.0, 0.0, -3.0, 0.0);
    float4 normal = float4(vertexIn.normal, 0);
    
    float4 tnorm = normalize(uniforms.projectionMatrix * uniforms.modelViewMatrix * normal);
    float4 eyeCoords = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    float4 s = normalize(uniforms.lightPosition - eyeCoords);
    
    outVertex.lightIntensity = float4(uniforms.intensity, 1.0) * float4(uniforms.reflectivity, 1.0) * max( dot(s, tnorm), 0.0);
    outVertex.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    
    return outVertex;
};

fragment half4 lightingFragment(VertexOut inFrag [[stage_in]],
                                constant Uniforms &uniforms [[buffer(0)]])
{
    return half4(inFrag.lightIntensity * uniforms.color);
};
