package main

import (
	"dagger.io/dagger"
)

dagger.#Plan & {
	actions: {
		image: dagger.#Pull & {
			source: "alpine:3.15.0@sha256:e7d88de73db3d3fd9b2d63aa7f447a10fd0220b7cbf39803c803f2af9ba256b3"
		}

		generate: dagger.#Exec & {
			input: image.output
			args: ["sh", "-c", "echo ' test ' > /secret"]
		}

		load: dagger.#NewSecret & {
			input:     generate.output
			trimSpace: false
			path:      "/secret"
		}

		trim: dagger.#TrimSecret & {
			input: load.output
		}

		verify: dagger.#Exec & {
			input: image.output
			mounts: secret: {
				dest:     "/run/secrets/test"
				contents: trim.output
			}
			args: [
				"sh", "-c",
				#"""
					test "$(cat /run/secrets/test)" = "test"
					"""#,
			]
		}
	}
}
