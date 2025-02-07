import UIKit

final class LoadingView: UIVisualEffectView {
  private let animationDuration: TimeInterval = 0.15
  private let blurEffect = UIBlurEffect(style: .dark)
  private let activityIndicator = UIActivityIndicatorView(style: .large)

  init(parent: UIView) {
      super.init(effect: blurEffect)
      translatesAutoresizingMaskIntoConstraints = false
      parent.addSubview(self)
      NSLayoutConstraint.activate([
          topAnchor.constraint(equalTo: parent.topAnchor),
          leadingAnchor.constraint(equalTo: parent.leadingAnchor),
          trailingAnchor.constraint(equalTo: parent.trailingAnchor),
          bottomAnchor.constraint(equalTo: parent.bottomAnchor),
      ])
      setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    isUserInteractionEnabled = false
    layer.zPosition = 10

    contentView.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.color = .white
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])
    activityIndicator.startAnimating()
  }

  func show() {
    self.layer.removeAllAnimations()
    self.isHidden = false
    UIView.animate(withDuration: self.animationDuration) {
      self.alpha = 1
      self.effect = self.blurEffect
    }
  }

  func hide() {
    self.layer.removeAllAnimations()
    UIView.animate(withDuration: self.animationDuration) {
      self.alpha = 0
      self.effect = nil
    } completion: { _ in
      self.isHidden = true
    }
  }
}
