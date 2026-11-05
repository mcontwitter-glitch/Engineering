// Ghidra postScript: export decompiled C, imports, strings
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import ghidra.program.model.data.StringDataInstance;
import java.io.*;
public class ExportDecomp extends GhidraScript {
  public void run() throws Exception {
    String out = getScriptArgs()[0];
    DecompInterface d = new DecompInterface(); d.openProgram(currentProgram);
    try (PrintWriter c = new PrintWriter(out + "/decompiled.c");
         PrintWriter f = new PrintWriter(out + "/functions.txt")) {
      for (Function fn : currentProgram.getFunctionManager().getFunctions(true)) {
        if (monitor.isCancelled()) break;
        f.println(fn.getEntryPoint() + "\t" + fn.getName() + (fn.isExternal()||fn.isThunk() ? "\t[thunk/ext]" : ""));
        if (fn.isExternal() || fn.isThunk()) continue;
        DecompileResults r = d.decompileFunction(fn, 30, monitor);
        c.println("// " + fn.getName() + " @ " + fn.getEntryPoint());
        c.println(r.decompileCompleted() ? r.getDecompiledFunction().getC() : "// decompile failed: " + r.getErrorMessage());
      }
    }
    try (PrintWriter i = new PrintWriter(out + "/imports.txt")) {
      for (Symbol s : currentProgram.getSymbolTable().getExternalSymbols())
        i.println(s.getParentNamespace().getName() + "\t" + s.getName());
    }
    try (PrintWriter s = new PrintWriter(out + "/strings.txt")) {
      for (Data dt : currentProgram.getListing().getDefinedData(true)) {
        StringDataInstance sdi = StringDataInstance.getStringDataInstance(dt);
        if (sdi != StringDataInstance.NULL_INSTANCE && sdi.getStringValue()!=null) s.println(dt.getAddress()+"\t"+sdi.getStringValue());
      }
    }
    d.dispose();
  }
}
