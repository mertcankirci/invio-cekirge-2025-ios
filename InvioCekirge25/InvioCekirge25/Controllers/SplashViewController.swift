//
//  SplashViewController.swift
//  InvioCekirge25
//
//  Created by Mertcan Kırcı on 27.03.2025.
//

import UIKit

class SplashViewController: UIViewController {

    private var logoImageView = UIImageView()
    let service = APIService()
    var locationResults: LocationResultModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureImageView()
        configureUI()
        fetchDataAndSwitchScreens()
    }
    
    func configureVC() {
        view.backgroundColor = InvioColors.groupedBackground
    }
    
    func configureImageView() {
        logoImageView.image = UIImage(named: "invioIcon")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureUI() {
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 220),
            logoImageView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
}

extension SplashViewController {
    private func fetchDataAndSwitchScreens() {
        Task { [weak self] in
            guard let self = self else { return }

            do {
                let results = try await self.service.fetchData()
                await MainActor.run {
                    self.locationResults = results
                    self.routeToMainScreen()
                }
            } catch {
                await MainActor.run {
                    self.presentAlert(errorMessage: error.localizedDescription)
                }
            }
        }
    }
    
    private func routeToMainScreen() {
        //Haptic feedback
        DispatchQueue.main.async { [weak self] in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            UIView.animate(withDuration: 0.4) {
                self?.logoImageView.alpha = 0
            } completion: { _ in
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let delegate = scene.delegate as? SceneDelegate,
                      let results = self?.locationResults else { return }
                
                delegate.switchToMainScreen(with: results)
            }
        }
    }
}
