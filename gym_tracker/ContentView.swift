import SwiftUI

struct ContentView: View {
    let screenSize: CGRect = UIScreen.main.bounds
    @State private var showingFront = true
    
    @State private var isBottomSheetPresented = false
    @State private var field1 = ""
    @State private var field2 = ""
    @State private var field3 = ""
    
    init() {
        DatabaseManager.shared.insertBodyParts();
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                Ellipse()
                    .fill(Color.blue)
                    .frame(width: 500, height: 650)
                    .offset(x: -250, y: -100)
                    .blur(radius: 250)
                VStack(spacing: 0){
                    FSCalendarWeekView(
                        highlightedDates: [
                            /*Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 29))!*/
                        ]
                    )
                    .frame(width: screenSize.width, height: 200)
                    Spacer()
                }
                VStack(spacing: 0) {
                    ZStack{
                        Image(showingFront ? "empty_front" : "empty_back")
                            .resizable()
                            .scaledToFit()
                            .padding(EdgeInsets(top: 65, leading: 100, bottom: 0, trailing: 100))
                        Image(showingFront ? "chest" : "glutes")
                            .resizable()
                            .scaledToFit()
                            .padding(EdgeInsets(top: 65, leading: 100, bottom: 0, trailing: 100))
                    }
                    Spacer()
                    Button(action: {
                        showingFront.toggle()
                    }) {
                        Text(showingFront ? "Back" : "Front")
                            .foregroundColor(.blue)
                            .frame(width: 200, height: 30)
                            .background(Color.blue.opacity(0.125))
                            .cornerRadius(15 / 2)
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isBottomSheetPresented.toggle()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                    }
                    .padding(.trailing, 65)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    VStack{
                        NavigationLink {
                            Stats()
                        } label: {
                            Image(systemName: "chart.xyaxis.line")
                                .foregroundColor(.blue)
                                .font(.system(size: 17.5))
                        }
                    }
                }
            }
            .sheet(isPresented: $isBottomSheetPresented) {
                BottomSheetView(isPresented: $isBottomSheetPresented, field1: $field1, field2: $field2, field3: $field3)
                    .onAppear {
                        setWindowBackgroundColor(UIColor(hex: "#04182E") ?? .black)
                    }
            }
        }
    }
    
    private func setWindowBackgroundColor(_ color: UIColor) {
        if let window = UIApplication.shared.windows.first {
            window.backgroundColor = color
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
