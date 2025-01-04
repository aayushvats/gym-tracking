import SwiftUI

struct Stats: View {
    
    init() {
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
                ///Background
                Color.black.edgesIgnoringSafeArea(.all)
                Ellipse()
                 .fill(Color.blue)
                 .frame(width: 500, height: 650)
                 .offset(x: -200, y: -100)
                 .blur(radius: 250)
                VStack{
                    Text("https://musclewiki.com/")
                }.navigationTitle("Statistics")
            }
        }
    }
}

#Preview {
    Stats()
}
