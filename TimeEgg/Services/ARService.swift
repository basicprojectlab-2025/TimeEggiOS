//
//  ARService.swift
//  TimeEgg
//
//  Created by donghyeon choi on 9/22/25.
//

import Foundation
import ARKit
import RealityKit
import UIKit
import Combine

class ARService: NSObject, ObservableObject {
    var objectWillChange: ObservableObjectPublisher
    
    private var arView: ARView?
    private var arSession: ARSession?
    
    @Published var isARSessionRunning = false
    @Published var errorMessage: String?
    
    override init() {
        self.objectWillChange = ObservableObjectPublisher()
        super.init()
    }
    
    // MARK: - AR Session Management
    
    func setupARSession() -> ARView? {
        guard ARWorldTrackingConfiguration.isSupported else {
            errorMessage = "AR World Tracking이 지원되지 않는 기기입니다."
            return nil
        }
        
        let arView = ARView(frame: .zero)
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        arSession = arView.session
        isARSessionRunning = true
        
        return arView
    }
    
    func startARSession() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        isARSessionRunning = true
    }
    
    func pauseARSession() {
        arView?.session.pause()
        isARSessionRunning = false
    }
    
    // MARK: - AR Photo Capture
    
    func captureARPhoto() async -> UIImage? {
        guard let arView = arView else {
            errorMessage = "AR 세션이 설정되지 않았습니다."
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            arView.snapshot(saveToHDR: false) { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - AR Content Management
    
    func add3DObjectToAR(_ objectName: String, at position: SIMD3<Float>) {
        guard let arView = arView else { return }
        
        // 3D 오브젝트 엔티티 생성
        let objectEntity = create3DObjectEntity(name: objectName)
        objectEntity.position = position
        
        // AR 씬에 추가
        let anchor = AnchorEntity(world: position)
        anchor.addChild(objectEntity)
        arView.scene.addAnchor(anchor)
    }
    
    // MARK: - AR Plane Detection
    
    func enablePlaneDetection() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func disablePlaneDetection() {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - AR Anchors
    
    func addAnchor(at position: SIMD3<Float>) -> AnchorEntity? {
        guard let arView = arView else { return nil }
        
        let anchor = AnchorEntity(world: position)
        arView.scene.addAnchor(anchor)
        return anchor
    }
    
    func removeAnchor(_ anchor: AnchorEntity) {
        arView?.scene.removeAnchor(anchor)
    }
    
    // MARK: - Helper Methods
    
    private func create3DObjectEntity(name: String) -> ModelEntity {
        // 기본 3D 오브젝트 엔티티 생성
        let mesh = MeshResource.generateBox(size: 0.2)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        return entity
    }
    
    // MARK: - AR World Map
    
    func saveWorldMap() async -> ARWorldMap? {
        guard let arSession = arSession else { return nil }
        
        return await withCheckedContinuation { continuation in
            arSession.getCurrentWorldMap { worldMap, error in
                if let error = error {
                    print("월드맵 저장 실패: \(error)")
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: worldMap)
                }
            }
        }
    }
    
    func loadWorldMap(_ worldMap: ARWorldMap) {
        guard let arView = arView else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - ARSessionDelegate
extension ARService: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // AR 프레임 업데이트 처리
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // AR 앵커 추가 처리
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // AR 앵커 업데이트 처리
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        // AR 앵커 제거 처리
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        errorMessage = "AR 세션 오류: \(error.localizedDescription)"
        isARSessionRunning = false
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        isARSessionRunning = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // AR 세션 재시작
        startARSession()
    }
}
