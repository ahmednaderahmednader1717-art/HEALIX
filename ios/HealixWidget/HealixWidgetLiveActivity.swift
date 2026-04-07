import SwiftUI
import WidgetKit
import ActivityKit

// This struct must exactly match the one implicitly used by the live_activities Flutter package.
@available(iOS 16.1, *)
public struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {
        var appGroupId: String
    }

    public var id = UUID()
}

@available(iOS 16.1, *)
extension LiveActivitiesAppAttributes {
    func sharedUserDefaults(state: ContentState) -> UserDefaults? {
        return UserDefaults(suiteName: state.appGroupId)
    }
    
    func getDouble(state: ContentState, key: String, defaultValue: Double = 0.0) -> Double {
        return sharedUserDefaults(state: state)?.double(forKey: "\(self.id)_\(key)") ?? defaultValue
    }
}

// Updated widget targeting the correct generic attributes structure.
@available(iOS 16.1, *)
struct HealixWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock Screen View
            HealixLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Today")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        VStack(alignment: .leading) {
                            Text(String(format: "%.0f", context.attributes.getDouble(state: context.state, key: "caloriesLeft")))
                                .font(.system(size: 24, weight: .bold))
                            Text("Calories left")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.leading, 10)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .padding(.trailing, 10)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 15) {
                        MacroIndicator(label: "Prot.", value: context.attributes.getDouble(state: context.state, key: "proteinLeft"), icon: "bolt.fill", color: .red)
                        MacroIndicator(label: "Carb.", value: context.attributes.getDouble(state: context.state, key: "carbsLeft"), icon: "leaf.fill", color: .green)
                        MacroIndicator(label: "Fats", value: context.attributes.getDouble(state: context.state, key: "fatsLeft"), icon: "drop.fill", color: .yellow)
                    }
                    .padding(.bottom, 10)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text(String(format: "%.0f", context.attributes.getDouble(state: context.state, key: "caloriesLeft"))).font(.system(size: 12, weight: .bold))
                }
            } compactTrailing: {
                Text(String(format: "%.0fg", context.attributes.getDouble(state: context.state, key: "proteinLeft"))).font(.system(size: 10, weight: .bold)).foregroundColor(.red)
            } minimal: {
                Image(systemName: "flame.fill").foregroundColor(.orange)
            }
        }
    }
}

@available(iOS 16.1, *)
struct HealixLiveActivityView: View {
    let context: ActivityViewContext<LiveActivitiesAppAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(red: 0.08, green: 0.19, blue: 0.23)) // #16313B
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                        }
                        .frame(width: 44, height: 44)
                        
                        Text(String(format: "%.0f", context.attributes.getDouble(state: context.state, key: "caloriesLeft")))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Calories left")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Divider().background(Color.white.opacity(0.2)).padding(.vertical, 20)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        MacroIndicatorVertical(label: "Protein", value: context.attributes.getDouble(state: context.state, key: "proteinLeft"), icon: "bolt.fill", color: .red)
                        MacroIndicatorVertical(label: "Carbs", value: context.attributes.getDouble(state: context.state, key: "carbsLeft"), icon: "leaf.fill", color: .green)
                        MacroIndicatorVertical(label: "Fats", value: context.attributes.getDouble(state: context.state, key: "fatsLeft"), icon: "drop.fill", color: .yellow)
                    }
                    .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 15)
        }
    }
}

struct MacroIndicator: View {
    let label: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(color).font(.system(size: 10))
            VStack(alignment: .leading, spacing: 0) {
                Text(String(format: "%.0fg", value)).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                Text(label).font(.system(size: 8)).foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

struct MacroIndicatorVertical: View {
    let label: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 32, height: 32)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 12))
            }
            Text(String(format: "%.0fg", value)).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
        }
    }
}
