//
//  GameViewController.swift
//  TeapotLighting
//
//  Created by Janie Clayton on 1/20/17.
//  Copyright © 2017 RedQueenCoder. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import simd

let MaxBuffers = 3
let ConstantBufferSize = 1024*1024

class GameViewController:UIViewController, MTKViewDelegate {
    
    var device: MTLDevice! = nil
    var meshes: [MTKMesh]!
    var uniformBuffer: MTLBuffer! = nil
    var commandQueue: MTLCommandQueue! = nil
    let vertexDescriptor = MTLVertexDescriptor()
    var pipelineState: MTLRenderPipelineState! = nil
    var rotationAngle: Float32 = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else { // Fallback to a blank UIView, an application could also fallback to OpenGL ES here.
            print("Metal is not supported on this device")
            self.view = UIView(frame: self.view.frame)
            return
        }

        // setup view properties
        let view = self.view as! MTKView
        view.device = device
        view.delegate = self
        
        loadAssets()
        initializeAssets()
    }
    
    func loadAssets() {
        
        // load any resources required for rendering
        let view = self.view as! MTKView
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"
        
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "lightingFragment")!
        let vertexProgram = defaultLibrary.makeFunction(name: "lightingVertex")!
        
        
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3 // position
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float3 // Vertex normal
        vertexDescriptor.layouts[0].stride = 24
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        
    }
    
    func initializeAssets() {
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeNormal
        let mtkBufferAllocator = MTKMeshBufferAllocator(device: device!)
        let url = Bundle.main.url(forResource: "wt_teapot", withExtension: "obj")
        let asset = MDLAsset(url: url!, vertexDescriptor: desc, bufferAllocator: mtkBufferAllocator)
        
        do {
            meshes = try MTKMesh.newMeshes(from: asset, device: device!, sourceMeshes: nil)
        }
        catch let error {
            fatalError("\(error)")
        }
        
        // Vector Uniforms
        let teapotColor = float4(0.7, 0.47, 0.18, 1.0)
        let lightPosition = float4(5.0, 5.0, 2.0, 1.0)
        let reflectivity = float3(1.0, 1.0, 1.0)
        let intensity = float3(2.0, 2.0, 2.0)
        
        // Matrix Uniforms
        let yAxis = Vector4(x: 0, y: -1, z: 0, w: 0)
        let modelViewMatrix = Matrix4x4.rotationAboutAxis(yAxis, byAngle: rotationAngle)
        let aspect = Float32(self.view.bounds.width) / Float32(self.view.bounds.height)
        
        let projectionMatrix = Matrix4x4.perspectiveProjection(aspect, fieldOfViewY: 60, near: 0.1, far: 100.0)
        
        let uniform = Uniforms(lightPosition: lightPosition, color: teapotColor, reflectivity: reflectivity, lightIntensity: intensity, projectionMatrix: projectionMatrix, modelViewMatrix: modelViewMatrix)
        let uniforms = [uniform]
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
        memcpy(uniformBuffer.contents(), uniforms, MemoryLayout<Uniforms>.size)
    }
    
    func draw(in view: MTKView) {
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        // Generate render pass descriptor
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.label = "render encoder"
            
            renderEncoder.setCullMode(MTLCullMode.back)
            renderEncoder.pushDebugGroup("draw teapot")
            renderEncoder.setRenderPipelineState(pipelineState)
            let mesh = (meshes?.first)!
            let vertexBuffer = mesh.vertexBuffers[0]
            renderEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, at: 0)
            renderEncoder.setVertexBuffer(uniformBuffer, offset:0, at:1)
            renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, at: 0)
            let submesh = mesh.submeshes.first!
            renderEncoder.drawIndexedPrimitives(type: submesh.primitiveType, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
                
            commandBuffer.present(currentDrawable)
        }
        
        commandBuffer.commit()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
