/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <fmt/core.h>
#include <openr/common/Types.h>

#include <openr/common/NetworkUtil.h>

namespace openr {

RegexSet::RegexSet(std::vector<std::string> const& keyPrefixList) {
  if (keyPrefixList.empty()) {
    return;
  }
  re2::RE2::Options re2Options;
  re2Options.set_case_sensitive(true);
  regexSet_ =
      std::make_unique<re2::RE2::Set>(re2Options, re2::RE2::ANCHOR_START);
  std::string re2AddError{};

  for (auto const& keyPrefix : keyPrefixList) {
    if (regexSet_->Add(keyPrefix, &re2AddError) < 0) {
      LOG(FATAL) << "Failed to add prefixes to RE2 set: '" << keyPrefix << "', "
                 << "error: '" << re2AddError << "'";
      return;
    }
  }
  if (!regexSet_->Compile()) {
    LOG(FATAL) << "Failed to compile re2 set";
  }
}

bool
RegexSet::match(std::string const& key) const {
  CHECK(regexSet_);
  std::vector<int> matches;
  return regexSet_->Match(key, &matches);
}

PrefixKey::PrefixKey(
    std::string const& node,
    folly::CIDRNetwork const& prefix,
    const std::string& area,
    bool isPrefixKeyV2)
    : nodeAndArea_(node, area),
      prefix_(prefix),
      isPrefixKeyV2_(isPrefixKeyV2),
      prefixKeyString_(fmt::format(
          "{}{}:{}:[{}/{}]",
          Constants::kPrefixDbMarker.toString(),
          node,
          area,
          prefix_.first.str(),
          prefix_.second)),
      prefixKeyStringV2_(fmt::format(
          "{}{}:[{}/{}]",
          Constants::kPrefixDbMarker.toString(),
          node,
          prefix_.first.str(),
          prefix_.second)) {}

bool
PrefixKey::isPrefixKeyV2Str(const std::string& key) {
  int64_t plen{0};
  std::string node{};
  std::string ipStr{};
  folly::CIDRNetwork ipAddress;
  auto patt =
      RE2::FullMatch(key, PrefixKey::getPrefixRE2(), &node, &ipStr, &plen);
  auto pattV2 =
      RE2::FullMatch(key, PrefixKey::getPrefixRE2V2(), &node, &ipStr, &plen);

  return (not patt) and pattV2;
}

folly::Expected<PrefixKey, std::string>
PrefixKey::fromStr(const std::string& key) {
  int plen{0};
  std::string area{};
  std::string node{};
  std::string ipstr{};
  folly::CIDRNetwork ipaddress;
  auto patt = RE2::FullMatch(key, getPrefixRE2(), &node, &area, &ipstr, &plen);
  if (!patt) {
    return folly::makeUnexpected(fmt::format("Invalid key format {}", key));
  }

  try {
    ipaddress =
        folly::IPAddress::createNetwork(fmt::format("{}/{}", ipstr, plen));
  } catch (const folly::IPAddressFormatException& e) {
    LOG(INFO) << "Exception in converting to Prefix. " << e.what();
    return folly::makeUnexpected(std::string("Invalid IP address in key"));
  }
  return PrefixKey(node, ipaddress, area, false);
}

folly::Expected<PrefixKey, std::string>
PrefixKey::fromStrV2(const std::string& key, const std::string& area) {
  int plen{0};
  std::string node{};
  std::string ipStr{};
  folly::CIDRNetwork ipAddress;
  auto patt = RE2::FullMatch(key, getPrefixRE2V2(), &node, &ipStr, &plen);
  if (!patt) {
    return folly::makeUnexpected(fmt::format("Invalid key format {}", key));
  }

  try {
    ipAddress =
        folly::IPAddress::createNetwork(fmt::format("{}/{}", ipStr, plen));
  } catch (const folly::IPAddressFormatException& e) {
    LOG(INFO) << "Exception in converting to Prefix. " << e.what();
    return folly::makeUnexpected(std::string("Invalid IP address in key"));
  }
  return PrefixKey(node, ipAddress, area, true);
}

} // namespace openr
