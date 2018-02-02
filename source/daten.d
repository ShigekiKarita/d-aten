module daten;
import std.stdio;

extern(C++, at) {
    abstract class TensorImpl {
        const(char*) toString() const;
        long dim() const;
    }

    private class UndefinedTensor : TensorImpl {
        import std.typecons : scoped;
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

immutable undefined = new at.UndefinedTensor;


unittest
{
    auto t = new at.Tensor;
    import core.stdcpp.exception;

    try {
        t.dim();
    } catch (core.stdcpp.exception.std.exception e) {
    }
    t.print();
    t.writeln;
}
