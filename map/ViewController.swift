import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var avgSpeed: UILabel!
    @IBOutlet weak var Distance: UILabel!
    @IBOutlet weak var maxAccelerate: UILabel!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var redview: UIView!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var startTripLocation: CLLocation?
    var preSpeed: CLLocationSpeed?
    var accelerationValue: Double = 0
    var speedValue: CLLocationSpeed = 0
    var totalSpeed: CLLocationSpeed = 0
    var speedCount: Int = 0
    var startTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSpeed.text = "0.00 km/h"
        maxSpeed.text = "0.00 km/h"
        avgSpeed.text = "0.00 km/h"
        Distance.text = "0.00 km"
        maxAccelerate.text = "0.00 m/s^2"
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 500, longitudinalMeters: 500)
        if startTripLocation == nil {
            speedValue = 0
            totalSpeed = 0
            speedCount = 0
            startTripLocation = location
            startTime = Date()
        }
        
        let speed = location.speed
        if speed > speedValue {
            speedValue = speed
        }
        
        totalSpeed += speed
        speedCount += 1
        
        redview.backgroundColor = speed * 3.6 > 115 ? .red : .systemGray6
        
        currentSpeed.text = "\(String(format: "%.2f", speed * 3.6)) km/h"
        maxSpeed.text = "\(String(format: "%.2f", speedValue * 3.6)) km/h"
        
        let tripDistance = location.distance(from: startTripLocation!) / 1000
        Distance.text = "\(String(format: "%.2f", tripDistance)) km"
    
        let averageSpeed = totalSpeed / Double(speedCount)
        avgSpeed.text = "\(String(format: "%.2f", averageSpeed * 3.6)) km/h"
        
        calculateAcceleration(CurrentSpeed: speed)
        
        map.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func onClickStart(_ sender: Any) {
        startTime = Date()
        greenView.backgroundColor = .green
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func onClickStop(_ sender: Any) {
        greenView.backgroundColor = .gray
        redview.backgroundColor = .systemGray6
        startTripLocation = nil
        startTime = nil
        locationManager.stopUpdatingLocation()
    }
    
    func calculateAcceleration(CurrentSpeed: CLLocationSpeed) {
        if preSpeed == nil {
            preSpeed = CurrentSpeed
        }
        let acceleration = abs(CurrentSpeed - preSpeed!)
        preSpeed = CurrentSpeed
        
        if acceleration > accelerationValue {
            accelerationValue = acceleration
            maxAccelerate.text = "\(String(format: "%.2f", accelerationValue * 3.6)) m/s^2"
        }
    }
}
