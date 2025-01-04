import SwiftUI

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    @Binding var field1: String
    @Binding var field2: String
    @Binding var field3: String
    
    @State private var selectedExercise: String? = nil
    @State private var selectedBodyParts: Set<Int64> = []  // Store BodyPartIDs instead of names
    @State private var exerciseSetCount: Double = 1
    @State private var exerciseRepCount: Double = 1
    @State private var exerciseWeight: Double = 2.5
    @State private var exerciseChips: [String] = ["Push-up", "Pull-up", "Squat", "Deadlift", "Bench Press"]
    
    // Change to an array of tuples (BodyPartID, BodyPart Name)
    @State private var bodyParts: [(Int64, String)] = []

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Ellipse()
                .fill(Color.blue)
                .frame(width: 500, height: 650)
                .offset(x: -250, y: -100)
                .blur(radius: 250)
            
            VStack(spacing: 16) {
                Spacer().frame(height: 10)
                Text("Add Exercise")
                    .font(.largeTitle)
                    .colorInvert()
                
                // Exercise Name or Selection
                if selectedExercise == nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack {
                            TextField("Enter exercise name", text: $field1)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                if !field1.isEmpty {
                                    exerciseChips.append(field1)
                                    selectedExercise = field1
                                    field1 = ""
                                }
                            }) {
                                Text("Add")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(exerciseChips, id: \.self) { exercise in
                                    ChipView(
                                        text: exercise,
                                        isSelected: selectedExercise == exercise,
                                        selectedColor: Color.clear,
                                        unselectedColor: Color.white.opacity(0.5),
                                        textColor: selectedExercise == exercise ? .white : .black,
                                        textSize: selectedExercise == exercise ? .largeTitle : .body
                                    ) {
                                        selectedExercise = selectedExercise == exercise ? nil : exercise
                                        if selectedExercise != nil {
                                            field1 = ""
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    // Show selected exercise chip
                    HStack {
                        ChipView(
                            text: selectedExercise ?? "",
                            isSelected: true,
                            selectedColor: Color.clear,
                            unselectedColor: Color.white.opacity(0.5),
                            textColor: .white,
                            textSize: .largeTitle
                        ) {
                            selectedExercise = nil
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Body Parts Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Targeted Body Parts")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(bodyParts, id: \.0) { part in
                                ChipView(
                                    text: part.1,  // Display BodyPart name
                                    isSelected: selectedBodyParts.contains(part.0),  // Check if BodyPartID is selected
                                    selectedColor: Color.blue,
                                    unselectedColor: Color.white.opacity(0.5),
                                    textColor: selectedBodyParts.contains(part.0) ? .white : .black,
                                    textSize: .body
                                ) {
                                    // Toggle BodyPartID in selectedBodyParts Set
                                    if selectedBodyParts.contains(part.0) {
                                        selectedBodyParts.remove(part.0)
                                    } else {
                                        selectedBodyParts.insert(part.0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Sets Selector
                numberSelectorField(label: "Sets", value: $exerciseSetCount, step: 1, minValue: 1, maxValue: 100)
                
                // Reps Selector
                numberSelectorField(label: "Reps", value: $exerciseRepCount, step: 1, minValue: 1, maxValue: 100)
                
                // Weight Selector
                numberSelectorField(label: "Weight (kg)", value: $exerciseWeight, step: 2.5, minValue: 0.0, maxValue: 500.0)
                
                // Submit Button
                Spacer()
                Button(action: {
                    print("Exercise: \(selectedExercise ?? field1)")
                    print("Body Parts: \(selectedBodyParts.map { String($0) }.joined(separator: ", "))")
                    print("Sets: \(exerciseSetCount), Reps: \(exerciseRepCount), Weight: \(exerciseWeight) kg")
                    isPresented = false
                }) {
                    Text("Submit")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal, 60)
        }
        .onAppear {
            // Fetch all body parts from the database when the view appears
            self.bodyParts = DatabaseManager.shared.fetchAllBodyParts()
        }
    }
    
    @ViewBuilder
    private func numberSelectorField(label: String, value: Binding<Double>, step: Double, minValue: Double, maxValue: Double) -> some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Button(action: {
                    value.wrappedValue = max(minValue, value.wrappedValue - step)
                }) {
                    Text("-")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                }
                
                Text(String(format: "%.1f", value.wrappedValue))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, alignment: .center)
                
                Button(action: {
                    value.wrappedValue = min(maxValue, value.wrappedValue + step)
                }) {
                    Text("+")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}

// ChipView Component
struct ChipView: View {
    let text: String
    let isSelected: Bool
    let selectedColor: Color
    let unselectedColor: Color
    let textColor: Color
    let textSize: Font
    let action: () -> Void
    
    var body: some View {
        Text(text)
            .font(textSize)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? selectedColor : unselectedColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
            .onTapGesture {
                action()
            }
    }
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetView(
            isPresented: .constant(true),
            field1: .constant(""),
            field2: .constant(""),
            field3: .constant("")
        )
    }
}
