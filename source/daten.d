module daten;
import std.stdio;

extern(C++, at) {
    class Context {
        // this();
        void doInitCUDA();
        bool hasCUDA() const;
    }

    class Type {
        Context context;
        this(Context context) {
            this.context = context;
        }
    }

    abstract class TensorImpl {
        const(char*) toString() const;
        long dim() const;
    }

    private class UndefinedTensor : TensorImpl {
        override const(char*) toString() const;
        override long dim() const;
    }

    extern(C++, detail) {
        class TensorBase {
            const TensorImpl pImpl;
            this () {
                pImpl = undefined;
            }

            long dim() const {
                return pImpl.dim();
            }

            bool defined() const {
                return &pImpl == &undefined;
            }
        }
    }

    class Tensor : detail.TensorBase {
        void print() const;
        auto toString() const {
            import std.string;
            return pImpl.toString().fromStringz;
        }
    }
}

import std.typecons : scoped;
immutable undefined = new at.UndefinedTensor;


unittest
{
    auto ctx = new Context;
    // ctx.doInitCUDA();
    // assert(ctx.hasCUDA());

    auto t = new at.Tensor;
    assert(!t.defined());

    import E = core.stdcpp.exception;
    bool raised = false;
    try {
        t.dim();
    } catch (E.std.exception e) {
        raised = true;
    }
    assert(raised);
    t.writeln;
    assert(t.toString == "UndefinedTensor");
}
