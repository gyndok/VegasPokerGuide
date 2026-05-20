import SwiftUI

/// Container with the Felt & Foil card treatment: opaque card surface, foil hairline border,
/// optional title in display font, optional foil divider beneath the title.
struct SectionCard<Content: View>: View {
    let title: String?
    let titleAccent: Color?
    @ViewBuilder let content: Content

    init(title: String? = nil,
         titleAccent: Color? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.titleAccent = titleAccent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s) {
            if let title {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.s) {
                    Text(title)
                        .font(AppFont.sectionLabel)
                        .tracking(1.4)
                        .foregroundStyle(titleAccent ?? AppColor.Text.secondary)
                    Spacer(minLength: 0)
                }
                AppHairline.divider(opacity: 0.5)
            }
            content
        }
        .padding(AppSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardSurface, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .foilBorder(cornerRadius: AppRadius.card, width: 0.5, opacity: 0.7)
    }
}

#Preview("SectionCard") {
    func cards() -> some View {
        VStack(spacing: AppSpacing.m) {
            SectionCard(title: "STARRED EVENTS") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("4 events").font(AppFont.eventName).foregroundStyle(AppColor.Text.primary)
                    Text("Total buy-in: $2,400").font(AppFont.meta).foregroundStyle(AppColor.Text.secondary)
                }
            }
            SectionCard {
                Text("No title — body only").font(AppFont.bodyCopy).foregroundStyle(AppColor.Text.primary)
            }
            SectionCard(title: "LONG TITLE THAT WRAPS UNNATURALLY FOR EDGE CASE TESTING") {
                Text("Long body. Long body. Long body. Long body. Long body. Long body. Long body. Long body.")
                    .font(AppFont.bodyCopy).foregroundStyle(AppColor.Text.primary)
            }
        }
        .padding()
    }
    return VStack(spacing: 24) {
        VStack { Text("Light").font(.caption); cards() }
            .background(AppColor.Paper.cream).environment(\.colorScheme, .light)
        VStack { Text("Dark").font(.caption); cards() }
            .background(AppColor.Rail.true).environment(\.colorScheme, .dark)
    }
}
