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
        Task {  [weak self] in
            guard let self = self else { return }
            do {
                self.locationResults = try await service.fetchData()
                self.routeToMainScreen()
            } catch {
                //MARK: - Kullaniciya hata mesaji
                presentAlert(errorMessage: error.localizedDescription)
            }
        }
    }
    
    private func routeToMainScreen() {
        //Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate,
              let results = locationResults else { return }
        
        delegate.switchToMainScreen(with: results)
    }
}
