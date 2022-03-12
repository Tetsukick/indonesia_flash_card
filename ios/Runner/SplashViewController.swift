import UIKit
import Lottie

public class SplashViewController: UIViewController {

    private var animationView: AnimationView?

    public override func viewDidAppear(_ animated: Bool) {
        animationView = .init(name: "splash_screen")
        animationView!.frame = view.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .playOnce
        animationView!.animationSpeed = 1.00
        view.addSubview(animationView!)
        animationView!.play{ (finished) in
            self.startFlutterApp()
        }
    }

    func startFlutterApp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterEngine = appDelegate.flutterEngine
        let flutterViewController =
            FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        UIApplication.shared.keyWindow?.rootViewController = flutterViewController
    }
 }
