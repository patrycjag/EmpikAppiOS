import Domain
import SwiftUI

struct LocationRow: View {
    let location: Location
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                if !location.detailsDescription.isEmpty {
                    Text(location.detailsDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            if let flag = location.flagEmoji {
                Text(flag)
                    .accessibilityHidden(true)
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

extension Location {
    var flagEmoji: String? {
        guard let code = countryCode?.uppercased(), code.count == 2 else { return nil }

        var flag = ""
        for scalar in code.unicodeScalars {
            guard
                ("A"..."Z").contains(scalar),
                let indicator = Unicode.Scalar(0x1F1E6 + scalar.value - 0x41)
            else { return nil }
            flag.unicodeScalars.append(indicator)
        }
        return flag
    }
}
