/**
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************
 */

#import "objc/hybrid/TINKHybridEncryptInternal.h"

#import "objc/util/TINKErrors.h"
#import "objc/util/TINKStrings.h"

#include "absl/strings/string_view.h"
#include "cc/hybrid_encrypt.h"

@implementation TINKHybridEncryptInternal

- (instancetype)initWithPrimitive:(crypto::tink::HybridEncrypt *)primitive {
  if (self = [super init]) {
    _primitive = primitive;
  }
  return self;
}

- (void)dealloc {
  delete _primitive;
}

- (NSData *)encrypt:(NSData *)plaintext
    withContextInfo:(NSData *)contextInfo
              error:(NSError **)error {
  if (error) {
    *error = nil;
  }

  absl::string_view context;
  if (contextInfo && contextInfo.length > 0) {
    context = absl::string_view(static_cast<const char *>(contextInfo.bytes),
                                            contextInfo.length);
  }

  auto st = _primitive->Encrypt(
      absl::string_view(static_cast<const char *>(plaintext.bytes), plaintext.length),
      context);
  if (!st.ok()) {
    *error = TINKStatusToError(st.status());
    return nil;
  }

  return TINKStringToNSData(st.ValueOrDie());
}

@end
