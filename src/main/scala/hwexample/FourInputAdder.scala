package hwexample

import chisel3._
import chisel3.util._
import chisel3.experimental.ExtModule
import io.circe._
import io.circe.parser._
import io.circe.generic.semiauto._
import scala.io.Source

/** Black box for Adder32 hard macro (32-bit + 32-bit → 33-bit) */
class Adder32 extends ExtModule {
  override val desiredName = "Adder32_verilog"
  val io_a = IO(Input(UInt(32.W)))
  val io_b = IO(Input(UInt(32.W)))
  val io_sum = IO(Output(UInt(33.W)))
}

/** Black box for Adder33 hard macro (33-bit + 33-bit → 34-bit) */
class Adder33 extends ExtModule {
  override val desiredName = "Adder33_verilog"
  val io_a = IO(Input(UInt(33.W)))
  val io_b = IO(Input(UInt(33.W)))
  val io_sum = IO(Output(UInt(34.W)))
}

case class FourInputAdderParams(
  registerInputs: Boolean = true,
  registerOutput: Boolean = true
)

object FourInputAdderParams {
  implicit val decoder: Decoder[FourInputAdderParams] = deriveDecoder[FourInputAdderParams]

  def fromFile(fileName: String): FourInputAdderParams = {
    val jsonContent = Source.fromFile(fileName).mkString
    decode[FourInputAdderParams](jsonContent) match {
      case Right(params) => params
      case Left(error) =>
        println(s"Failed to parse JSON: ${error}")
        System.exit(1)
        null
    }
  }
}

/** Four-input 32-bit adder using hard macros.
  *
  * Computes: sum = a0 + a1 + a2 + a3
  *
  * Architecture:
  *   - Adder32_0: a0 + a1 → s0 (33-bit)
  *   - Adder32_1: a2 + a3 → s1 (33-bit)
  *   - Adder33:   s0 + s1 → sum (34-bit)
  */
class FourInputAdder(params: FourInputAdderParams) extends Module {
  val io = IO(new Bundle {
    val a0 = Input(UInt(32.W))
    val a1 = Input(UInt(32.W))
    val a2 = Input(UInt(32.W))
    val a3 = Input(UInt(32.W))
    val sum = Output(UInt(34.W))
  })

  // Instantiate hard macros
  val adder32_0 = Module(new Adder32)
  val adder32_1 = Module(new Adder32)
  val adder33 = Module(new Adder33)

  if (params.registerInputs) {
    // Register inputs before feeding to first-stage adders
    adder32_0.io_a := RegNext(io.a0)
    adder32_0.io_b := RegNext(io.a1)
    adder32_1.io_a := RegNext(io.a2)
    adder32_1.io_b := RegNext(io.a3)
  } else {
    adder32_0.io_a := io.a0
    adder32_0.io_b := io.a1
    adder32_1.io_a := io.a2
    adder32_1.io_b := io.a3
  }

  // Connect first stage outputs to second stage
  adder33.io_a := adder32_0.io_sum
  adder33.io_b := adder32_1.io_sum

  if (params.registerOutput) {
    io.sum := RegNext(adder33.io_sum)
  } else {
    io.sum := adder33.io_sum
  }
}

/** Generator for FourInputAdder module */
object FourInputAdderGenerator extends ModuleGenerator {
  override def makeModule(args: Seq[String]): Module = {
    if (args.isEmpty) {
      println("Usage: <command> <outputDir> <configFile>")
      null
    } else {
      val params = FourInputAdderParams.fromFile(args(0))
      new FourInputAdder(params)
    }
  }
}

object FourInputAdderMain extends App {
  if (args.length < 2) {
    println("Usage: <outputDir> <configFile>")
    System.exit(1)
  }
  val outputDir = args(0)
  val configFile = args(1)
  FourInputAdderGenerator.generate(outputDir, Seq(configFile))
}
