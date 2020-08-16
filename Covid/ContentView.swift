//
//  ContentView.swift
//  Covid
//
//  Created by Joel Thomson on 8/16/20.
//  Copyright © 2020 Techcrus Labs. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct Home : View {
    
    @ObservedObject var data = getData()
    var body : some View {
        
        VStack{
            if self.data.counties.count != 0 && self.data.data != nil  {
                
                VStack{
                    
                    HStack(alignment: .top){
                        
                        VStack(alignment: .leading, spacing: 15) {
                            
                            Text(getData(time: self.data.data.updated))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Covid 19 Cases")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(getValue(data: self.data.data.cases))
                                .fontWeight(.bold)
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.data.data = nil
                            self.data.counties.removeAll()
                            self.data.updateData()

                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                    }.padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 18)
                    .padding()
                    .padding(.bottom, 80)
                    .background(Color.red)
                    
                    HStack(spacing: 15) {
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Deaths")
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            Text(getValue(data: self.data.data.deaths))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recovered")
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            Text(getValue(data: self.data.data.recovered))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                    }
                    .offset(y: -60)
                    .padding(.bottom, -60)
                    .zIndex(25)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Active Cases")
                            .foregroundColor(Color.black.opacity(0.5))
                        
                        Text(getValue(data: self.data.data.active))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.top, 15)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15){
                            
                            ForEach(self.data.counties, id: \.self){i in
                                cellView(data: i)
                            }.padding()
                        }
                    }
                    
                    
                }
                
            } else {
                GeometryReader{_ in
                    
                    VStack{
                        Indicator()
                    }
                    
                }
            }
            
        }.edgesIgnoringSafeArea(.top)
            .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
    }
}

func getDate(time : Double) -> String {
    
    let date = Double(time/1000)
    
    let format = DateFormatter()
    format.dateFormat = "MMM - dd - YYYY hh:mm a"
    return format.string(from: Date(timeIntervalSince1970: TimeInterval(exactly: Date)!))
    
}

func getValue(data : Double) -> String{
    let format = NumberFormatter()
    format.numberStyle = .decimal
    return format.string(for: data)!
}


struct cellView : View {
    
    var data : Details
    
    var body : some View{
        
        VStack(alignment: .leading, spacing: 15) {
            
            Text(data.country).fontWeight(.bold)
            
            HStack(spacing: 22){
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Cases").fontWeight(.bold).font(.title)
                    
                    Text(getValue(data: data.cases)).font(.title)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Deaths")
                        
                        Text(getValue(data: data.deaths))
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                                           
                        Text("Recovered")
                                           
                        Text(getValue(data: data.recovered))
                            .foregroundColor(.blue)
                    }
                                       
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                                           
                        Text("Critical")
                                           
                        Text(getValue(data: data.critical))
                            .foregroundColor(.yellow)
                    }
                              
                }
                
            }
            
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct Case : Decodable {
    
    var cases : Double
    var deaths : Double
    var updated : Double
    var recovered : Double
    var active : Double
}


struct Details : Decodable, Hashable {
    var country : String
    var cases : Double
    var deaths : Double
    var recovered : Double
    var critical : Double
}

class getData : ObservableObject {
    @Published var data : Case!
    @Published var counties = [Details]()
    
    init() {
        updateData()
    }
    
    func updateData() {
        let url = "https://corona.lmao.ninja/v3/covid-19/all"
        let url1 = "https://corona.lmao.ninja/v3/covid-19/countries/"
        
        let session = URLSession(configuration: .default)
        let session1 = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            
            let json = try! JSONDecoder().decode(Case.self, from: data!)
            
            DispatchQueue.main.async {
                
                self.data = json
            }
            
        }
        
        for i in country {
            
            session1.dataTask(with: URL(string: url1 + i)!) { (data, _, err) in
                
                if err != nil {
                    print((err?.localizedDescription)!)
                    return
                }
                
                let json = try! JSONDecoder().decode(Details.self, from: data!)
                
                DispatchQueue.main.async {
                    
                    self.counties.append(json)
                }
                
            }.resume()
        }
    }
}

var country = ["india", "usa", "italy", "spain", "australia", "uk", "china",]

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }

}
