package hwexample

import chisel3._
import chisel3.util._
import io.circe._
import io.circe.parser._
import io.circe.generic.semiauto._
import scala.io.Source

case class AdderParams(
  width: Int = 32,
  registerInputs: Boolean = true,
  registerOutput: Boolean = true
)

object AdderParams {
  implicit val adderParamsDecoder: Decoder[AdderParams] = deriveDecoder[AdderParams]

  def fromFile(fileName: String): AdderParams = {
    val jsonContent = Source.fromFile(fileName).mkString
    decode[AdderParams](jsonContent) match {
      case Right(params) => params
      case Left(error) =>
        println(s"Failed to parse JSON: ${error}")
        System.exit(1)
        null
    }
  }
}

/** Parameterized adder module.
  *
  * A simple registered adder for demonstrating the Chisel + Bazel + Nix flow.
  * Supports configurable bit width and optional input/output registers.
  *
  * @param params Configuration parameters for the adder
  */
class Adder(params: AdderParams) extends Module {
  val io = IO(new Bundle {
    val a = Input(UInt(params.width.W))
    val b = Input(UInt(params.width.W))
    val sum = Output(UInt((params.width + 1).W))
  })

  if (params.registerInputs && params.registerOutput) {
    // Both input and output registered
    val aReg = RegNext(io.a)
    val bReg = RegNext(io.b)
    io.sum := RegNext(aReg +& bReg)
  } else if (params.registerInputs) {
    // Only inputs registered
    val aReg = RegNext(io.a)
    val bReg = RegNext(io.b)
    io.sum := aReg +& bReg
  } else if (params.registerOutput) {
    // Only output registered
    io.sum := RegNext(io.a +& io.b)
  } else {
    // Purely combinational
    io.sum := io.a +& io.b
  }
}

/** Generator for Adder module */
object AdderGenerator extends ModuleGenerator {
  override def makeModule(args: Seq[String]): Module = {
    if (args.isEmpty) {
      println("Usage: <command> <outputDir> <configFile>")
      null
    } else {
      val params = AdderParams.fromFile(args(0))
      new Adder(params)
    }
  }
}

object AdderMain extends App {
  if (args.length < 2) {
    println("Usage: <outputDir> <configFile>")
    System.exit(1)
  }
  val outputDir = args(0)
  val configFile = args(1)
  AdderGenerator.generate(outputDir, Seq(configFile))
}
