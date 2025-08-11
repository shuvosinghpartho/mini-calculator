#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Assuming your yyparse function can be called and handles the input
// You would need to link with your compiled Flex/Bison code
extern int yyparse();
extern int yy_scan_string(const char *str);
extern void yy_delete_buffer();

// A global buffer to hold the result of the calculation
char result_buffer[256];

// The function that processes the expression from the text box
static void on_calculate_clicked(GtkWidget *widget, gpointer data) {
    GtkWidget *entry = (GtkWidget *)data;
    const char *expression = gtk_entry_get_text(GTK_ENTRY(entry));

    // You would need to adapt your Flex/Bison code to take a string as input
    // One way is to use yy_scan_string() to tell the scanner to read from a buffer
    yy_scan_string(expression);
    
    // Call the parser to evaluate the expression
    yyparse();
    
    // Reset the scanner for the next input
    yy_delete_buffer();

    // In a real implementation, your calculator would need a way
    // to return the result to this function, perhaps by writing it
    // to a global variable or a file.
    // For this example, let's assume `result_buffer` is updated.
    // For example:
    // snprintf(result_buffer, sizeof(result_buffer), "= %g", calculated_value);

    // Get the label to display the result
    GtkWidget *label = gtk_widget_get_parent(widget);
    GtkWidget *result_label = gtk_widget_get_prev_sibling(label);
    
    // Update the label with the result
    gtk_label_set_text(GTK_LABEL(result_label), result_buffer);
}

// The main function to create the GTK window
int main(int argc, char *argv[]) {
    GtkWidget *window;
    GtkWidget *vbox;
    GtkWidget *entry;
    GtkWidget *button;
    GtkWidget *result_label;

    gtk_init(&argc, &argv);

    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "Simple Calculator");
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_container_add(GTK_CONTAINER(window), vbox);

    entry = gtk_entry_new();
    gtk_box_pack_start(GTK_BOX(vbox), entry, FALSE, FALSE, 0);

    button = gtk_button_new_with_label("Calculate");
    gtk_box_pack_start(GTK_BOX(vbox), button, FALSE, FALSE, 0);
    g_signal_connect(button, "clicked", G_CALLBACK(on_calculate_clicked), entry);

    result_label = gtk_label_new("Result will appear here.");
    gtk_box_pack_start(GTK_BOX(vbox), result_label, FALSE, FALSE, 0);

    gtk_widget_show_all(window);

    gtk_main();

    return 0;
}