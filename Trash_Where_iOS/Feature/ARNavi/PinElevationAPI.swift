//
//  PinElevationAPI.swift
//  Trash_Where_iOS
//
//  Created by 이치훈 on 2023/08/05.
//

import Foundation

protocol PinElevationAPIDelegate {
  func didUpdateElevation(_ pinElevationAPI: PinElevationAPI, pinModel: [PinModel], type: RequestType)
  func didFailWithError(error: Error)
}

enum RequestType {
  case pinNode
  case coinNode
}

class PinElevationAPI {
  
  var deleagte: PinElevationAPIDelegate?
  var pinAPIModel: PinModel?
  
  public func fetchElevation(pinModel: PinModel, type: RequestType) {
    self.pinAPIModel = pinModel
    // TODO: API 비용 최적화작업
    if pinAPIModel == nil {
      print("PinModels is empty...")
      return
    }

    let locations = "\(pinModel.latitude)%2C\(pinModel.longitude)"
    
    let elevationURL = "https://api.open-elevation.com/api/v1/lookup?locations=\(locations)"
    
    performRequest(with: elevationURL, type: type)
  }
  
  private func performRequest(with urlString: String, type: RequestType) {
    if let url = URL(string: urlString) {
      let session = URLSession(configuration: .default)
      
      let task = session.dataTask(with: url) { data, response, error in
        if error != nil {
          self.deleagte?.didFailWithError(error: error!)
          return
        }
        
        if let hasData = data {
          if let parsePinModel = self.parseJSON(hasData) {
            self.deleagte?.didUpdateElevation(self, pinModel: parsePinModel, type: type)
          }
        } else {
          print("data miss...")
        }
      }
      task.resume()
    } else {
      print("url nil")
    }
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
