import unittest

from publish_release import certificate_digests


class CertificateOutputTest(unittest.TestCase):
    digest = "ab" * 32

    def test_numbered_signer(self):
        self.assertEqual(
            certificate_digests(f"Signer #1 certificate SHA-256 digest: {self.digest}\n"),
            {self.digest},
        )

    def test_sdk_range_signer_and_uppercase_digest(self):
        self.assertEqual(
            certificate_digests(
                "Signer (minSdkVersion=24, maxSdkVersion=2147483647) #1 "
                f"certificate SHA-256 digest: {self.digest.upper()}\n"
            ),
            {self.digest},
        )

    def test_preserves_distinct_certificates(self):
        other = "cd" * 32
        self.assertEqual(
            certificate_digests(
                f"Signer #1 certificate SHA-256 digest: {self.digest}\n"
                f"Signer #2 certificate SHA-256 digest: {other}\n"
            ),
            {self.digest, other},
        )

    def test_rejects_missing_or_truncated_digest(self):
        for result in ["", "Signer #1 certificate SHA-256 digest: abcd\n"]:
            with self.subTest(result=result), self.assertRaises(RuntimeError):
                certificate_digests(result)


if __name__ == "__main__":
    unittest.main()
