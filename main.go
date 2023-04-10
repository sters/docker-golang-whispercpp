package main

import (
	"fmt"
	"os"

	"github.com/ggerganov/whisper.cpp/bindings/go/pkg/whisper"
	gowav "github.com/go-audio/wav"
)

func run() error {
	fh, err := os.Open("tmp.wav")
	if err != nil {
		return err
	}
	defer fh.Close()

	dec := gowav.NewDecoder(fh)
	buf, err := dec.FullPCMBuffer()
	if err != nil {
		return err
	} else if dec.SampleRate != whisper.SampleRate {
		return fmt.Errorf("unsupported sample rate: %d", dec.SampleRate)
	} else if dec.NumChans != 1 {
		return fmt.Errorf("unsupported number of channels: %d", dec.NumChans)
	}

	samples := buf.AsFloat32Buffer().Data

	// model, err := whisper.New("ggml-medium.bin")
	// model, err := whisper.New("ggml-small.bin")
	model, err := whisper.New("ggml-tiny.bin")
	if err != nil {
		return err
	}
	defer model.Close()

	context, err := model.NewContext()
	if err != nil {
		return err
	}
	if err := context.Process(samples, nil); err != nil {
		return err
	}

	fmt.Println("\nWhisper read data =")

	// Print out the results
	for {
		segment, err := context.NextSegment()
		if err != nil {
			break
		}
		fmt.Printf("[%6s->%6s] %s\n", segment.Start, segment.End, segment.Text)
	}

	return nil
}

func main() {
	if err := run(); err != nil {
		panic(err)
	}
}
