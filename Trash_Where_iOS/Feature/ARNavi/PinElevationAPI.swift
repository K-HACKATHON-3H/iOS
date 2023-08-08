//
//  PinElevationAPI.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/05.
//

import Foundation

protocol PinElevationAPIDelegate {
  func didUpdateElevation(_ pinElevationAPI: PinElevationAPI, pinModel: [PinModel])
  func didFailWithError(error: Error)
}

class PinElevationAPI {
  
  var deleagte: PinElevationAPIDelegate?
  var pinAPIModels: [PinModel]?
  
  public func fetchElevation(pinModels: [PinModel]) {
    self.pinAPIModels = pinModels
    // TODO: API 비용 최적화작업
    if pinAPIModels == nil || pinAPIModels!.isEmpty {
      print("PinModels is empty...")
      return
    }

    let locations = makeLocationsURL()
    
    let elevationURL = "https://api.open-elevation.com/api/v1/lookup?locations=\(locations)"
    
    performRequest(with: elevationURL)
  }
  
  private func makeLocationsURL() -> String {
    var result = ""
    result.append("\(pinAPIModels![0].latitude)%2C\(pinAPIModels![0].longitude)")
    if pinAPIModels!.count == 1 {
      return result
    }
    for i in 1..<pinAPIModels!.count {
      result.append("%7C\(pinAPIModels![i].latitude)%2C\(pinAPIModels![i].longitude)")
    }

    print("makeLocationURL: \(result)")
    return result
  }
  
  private func performRequest(with urlString: String) {
    if let url = URL(string: urlString) {
      let session = URLSession(configuration: .default)
      
      let task = session.dataTask(with: url) { data, response, error in
        if error != nil {
          self.deleagte?.didFailWithError(error: error!)
          return
        }
        
        if let hasData = data {
          if let parsePinModel = self.parseJSON(hasData) {
            self.deleagte?.didUpdateElevation(self, pinModel: parsePinModel)
          }
        } else {
          print("data miss...")
        }
      }
      task.resume()
    } else {
      print("url nil")
    }
    
    print("performRequest...")
  }
  
  private func parseJSON(_ pinElevationData: Data) -> [PinModel]? {
    let decoder = JSONDecoder()
    do {
      let decodedData = try decoder.decode(PinElevationData.self, from: pinElevationData)
      
      var pinDatas = [PinModel]()
      
      _=decodedData.results.map {
        var pinmodel = PinModel(latitude: $0.latitude, longitude: $0.longitude)
        pinmodel.elevation = $0.elevation
        
        pinDatas.append(pinmodel)
        print("latitude: \(pinmodel.latitude), longitude: \(pinmodel.longitude), elevation: \(pinmodel.elevation)")
      }
            
      return pinDatas
    } catch {
      deleagte?.didFailWithError(error: error)
      return nil
    }
  }
  
}
